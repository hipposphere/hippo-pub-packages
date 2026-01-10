#include "hid_api_plugin.h"

#define NOMINMAX
#include <windows.h>
#include <hidsdi.h>
#include <setupapi.h>
#include <initguid.h>

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <vector>
#include <iostream>
#include <codecvt>
#include <thread>
#include <atomic>
#include <mutex>
#include <condition_variable>
#include <algorithm>

namespace hid_api {

class DisconnectionStreamHandler;
class ReportStreamHandler;
class DeviceUpdateStreamHandler;

// static
void HidApiPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "hid_api",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<HidApiPlugin>(registrar->messenger());

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

class DisconnectionStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  DisconnectionStreamHandler() : events_(nullptr) {}
  virtual ~DisconnectionStreamHandler() {}

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override {
    events_ = std::move(events);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
      const flutter::EncodableValue* arguments) override {
    events_ = nullptr;
    return nullptr;
  }

  void Notify() {
    if (events_) {
      events_->Success(flutter::EncodableValue());
    }
  }

 private:
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
};

class ReportStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  ReportStreamHandler(HANDLE device) : device_(device), running_(false) {}
  virtual ~ReportStreamHandler() { Stop(); }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override {
    events_ = std::move(events);
    running_ = true;
    thread_ = std::thread(&ReportStreamHandler::ReadLoop, this);
    return nullptr;
  }

  void SetDisconnectionHandler(DisconnectionStreamHandler* handler) {
    disconnection_handler_ = handler;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
      const flutter::EncodableValue* arguments) override {
    Stop();
    return nullptr;
  }

 private:
  void Stop() {
    running_ = false;
    if (thread_.joinable()) {
      thread_.join();
    }
  }

  void ReadLoop() {
    std::vector<uint8_t> buffer(256);
    OVERLAPPED ol = {0};
    ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

    while (running_) {
        DWORD bytesRead = 0;
        ResetEvent(ol.hEvent);
        
        BOOL readResult = ReadFile(device_, buffer.data(), (DWORD)buffer.size(), NULL, &ol);
        DWORD lastError = GetLastError();
        
        if (!readResult) {
            if (lastError == ERROR_IO_PENDING) {
                // Wait for the async operation to complete
                DWORD waitResult = WaitForSingleObject(ol.hEvent, 100);
                if (waitResult == WAIT_TIMEOUT) {
                    // Cancel the pending I/O operation before continuing
                    CancelIo(device_);
                    continue;
                }
                // Get the result of the completed async operation
                if (!GetOverlappedResult(device_, &ol, &bytesRead, FALSE)) {
                    lastError = GetLastError();
                    if (lastError == ERROR_DEVICE_NOT_CONNECTED || lastError == ERROR_GEN_FAILURE) {
                        if (disconnection_handler_) disconnection_handler_->Notify();
                        running_ = false;
                    }
                    continue;  // Don't process if GetOverlappedResult failed
                }
            } else if (lastError == ERROR_DEVICE_NOT_CONNECTED || lastError == ERROR_GEN_FAILURE) {
                if (disconnection_handler_) disconnection_handler_->Notify();
                running_ = false;
                continue;
            } else {
                // Other error, skip this iteration
                continue;
            }
        } else {
            // Synchronous completion - get the bytes read
            if (!GetOverlappedResult(device_, &ol, &bytesRead, FALSE)) {
                continue;  // Failed to get result, skip
            }
        }

        if (bytesRead > 0) {
            std::vector<uint8_t> data(buffer.begin(), buffer.begin() + bytesRead);
            flutter::EncodableMap result_map;
            result_map[flutter::EncodableValue("data")] = flutter::EncodableValue(data);
            result_map[flutter::EncodableValue("reportId")] = flutter::EncodableValue((int)buffer[0]);
            
            if (events_) {
                events_->Success(flutter::EncodableValue(result_map));
            }
        }
    }
    CloseHandle(ol.hEvent);
  }

  HANDLE device_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  DisconnectionStreamHandler* disconnection_handler_ = nullptr;
  std::thread thread_;
  std::atomic<bool> running_;
};

class DeviceUpdateStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  DeviceUpdateStreamHandler(HidApiPlugin* plugin) : plugin_(plugin), running_(false) {}
  virtual ~DeviceUpdateStreamHandler() { Stop(); }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override {
    events_ = std::move(events);
    running_ = true;
    thread_ = std::thread(&DeviceUpdateStreamHandler::WatchLoop, this);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
      const flutter::EncodableValue* arguments) override {
    Stop();
    return nullptr;
  }

 private:
  void Stop() {
    running_ = false;
    if (thread_.joinable()) thread_.join();
  }

  void WatchLoop() {
    std::vector<std::string> last_paths;
    bool first_run = true;
    while (running_) {
        flutter::EncodableList devices = plugin_->GetDeviceList();
        std::vector<std::string> current_paths;
        
        for (const auto& dev : devices) {
            if (auto map = std::get_if<flutter::EncodableMap>(&dev)) {
                auto it = map->find(flutter::EncodableValue("path"));
                if (it != map->end()) {
                    if (auto path_val = std::get_if<std::string>(&it->second)) {
                        current_paths.push_back(*path_val);
                    }
                }
            }
        }
        
        std::sort(current_paths.begin(), current_paths.end());

        bool changed = false;
        if (current_paths.size() != last_paths.size()) {
            changed = true;
        } else {
            for (size_t i = 0; i < current_paths.size(); i++) {
                if (current_paths[i] != last_paths[i]) {
                    changed = true;
                    break;
                }
            }
        }
        
        if (changed || first_run) {
             if (events_) {
                 events_->Success(flutter::EncodableValue(devices));
             }
             last_paths = current_paths;
             first_run = false;
        }

        std::this_thread::sleep_for(std::chrono::seconds(2));
    }
  }

  HidApiPlugin* plugin_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;
  std::thread thread_;
  std::atomic<bool> running_;
};

HidApiPlugin::HidApiPlugin(flutter::BinaryMessenger* messenger) : messenger_(messenger) {}

HidApiPlugin::~HidApiPlugin() {
    for (auto const& [path, handle] : open_devices_) {
        CloseHandle(handle);
    }
    for (auto const& [path, prepped] : preparsed_data_) {
        HidD_FreePreparsedData(prepped);
    }
    open_devices_.clear();
    preparsed_data_.clear();
    device_caps_.clear();
}

std::string WStringToString(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
}

std::string GetLastErrorAsString() {
    DWORD errorMessageID = GetLastError();
    if (errorMessageID == 0) return "No error";
    LPSTR messageBuffer = nullptr;
    size_t size = FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                                 NULL, errorMessageID, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPSTR)&messageBuffer, 0, NULL);
    std::string message(messageBuffer, size);
    LocalFree(messageBuffer);
    // Remove trailing newlines
    message.erase(std::remove(message.begin(), message.end(), '\r'), message.end());
    message.erase(std::remove(message.begin(), message.end(), '\n'), message.end());
    return message;
}

int ParseInterfaceNumber(const std::string& path) {
    // Windows paths look like: \\?\hid#vid_0911&pid_0c1c&mi_04#...
    // We look for &mi_ and grab the next two characters as a hex number
    size_t mi_pos = path.find("&mi_");
    if (mi_pos == std::string::npos) {
        return 0;
    }
    
    try {
        std::string mi_str = path.substr(mi_pos + 4, 2);
        return std::stoi(mi_str, nullptr, 16);
    } catch (...) {
        return 0;
    }
}

flutter::EncodableList HidApiPlugin::GetDeviceList() {
      GUID hidGuid;
      HidD_GetHidGuid(&hidGuid);
      
      HDEVINFO deviceInfoList = SetupDiGetClassDevs(&hidGuid, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
      if (deviceInfoList == INVALID_HANDLE_VALUE) {
          return flutter::EncodableList();
      }
      
      SP_DEVICE_INTERFACE_DATA deviceInterfaceData;
      deviceInterfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);
      
      flutter::EncodableList devices;
      
      for (DWORD i = 0; SetupDiEnumDeviceInterfaces(deviceInfoList, NULL, &hidGuid, i, &deviceInterfaceData); i++) {
          DWORD requiredSize = 0;
          SetupDiGetDeviceInterfaceDetail(deviceInfoList, &deviceInterfaceData, NULL, 0, &requiredSize, NULL);
          
          std::vector<BYTE> detailDataBuffer(requiredSize);
          PSP_DEVICE_INTERFACE_DETAIL_DATA deviceInterfaceDetailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)detailDataBuffer.data();
          deviceInterfaceDetailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);
          
          if (SetupDiGetDeviceInterfaceDetail(deviceInfoList, &deviceInterfaceData, deviceInterfaceDetailData, requiredSize, NULL, NULL)) {
              std::string path = WStringToString(deviceInterfaceDetailData->DevicePath);
              
              HANDLE handle = CreateFileA(path.c_str(), 0, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 0, NULL);
              if (handle != INVALID_HANDLE_VALUE) {
                  HIDD_ATTRIBUTES attributes;
                  attributes.Size = sizeof(HIDD_ATTRIBUTES);
                  if (HidD_GetAttributes(handle, &attributes)) {
                      PHIDP_PREPARSED_DATA preparsedData;
                      HIDP_CAPS caps;
                      
                      if (HidD_GetPreparsedData(handle, &preparsedData)) {
                          HidP_GetCaps(preparsedData, &caps);
                          HidD_FreePreparsedData(preparsedData);
                          
                          wchar_t buffer[126];
                          std::string manufacturer = "";
                          std::string product = "";
                          std::string serial = "";
                          
                          if (HidD_GetManufacturerString(handle, buffer, sizeof(buffer))) {
                              manufacturer = WStringToString(buffer);
                          }
                          if (HidD_GetProductString(handle, buffer, sizeof(buffer))) {
                              product = WStringToString(buffer);
                          }
                          if (HidD_GetSerialNumberString(handle, buffer, sizeof(buffer))) {
                              serial = WStringToString(buffer);
                          }
                          
                          flutter::EncodableMap deviceMap;
                          deviceMap[flutter::EncodableValue("path")] = flutter::EncodableValue(path);
                          deviceMap[flutter::EncodableValue("vendorId")] = flutter::EncodableValue((int)attributes.VendorID);
                          deviceMap[flutter::EncodableValue("productId")] = flutter::EncodableValue((int)attributes.ProductID);
                          deviceMap[flutter::EncodableValue("releaseNumber")] = flutter::EncodableValue((int)attributes.VersionNumber);
                          deviceMap[flutter::EncodableValue("usagePage")] = flutter::EncodableValue((int)caps.UsagePage);
                          deviceMap[flutter::EncodableValue("usage")] = flutter::EncodableValue((int)caps.Usage);
                          deviceMap[flutter::EncodableValue("manufacturer")] = flutter::EncodableValue(manufacturer);
                          deviceMap[flutter::EncodableValue("product")] = flutter::EncodableValue(product);
                          deviceMap[flutter::EncodableValue("serialNumber")] = flutter::EncodableValue(serial);
                          deviceMap[flutter::EncodableValue("interfaceNumber")] = flutter::EncodableValue(ParseInterfaceNumber(path));
                          
                          devices.push_back(flutter::EncodableValue(deviceMap));
                      }
                  }
                  CloseHandle(handle);
              }
          }
      }
      SetupDiDestroyDeviceInfoList(deviceInfoList);
      return devices;
}

void HidApiPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
  if (method_call.method_name().compare("initialize") == 0) {
      if (!device_update_channel_) {
          device_update_channel_ = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
              messenger_, "hid_api/device_updates", &flutter::StandardMethodCodec::GetInstance());
          auto handler = std::make_unique<DeviceUpdateStreamHandler>(this);
          device_update_channel_->SetStreamHandler(std::move(handler));
      }
      result->Success();
  } else if (method_call.method_name().compare("shutdown") == 0) {
      for (auto const& [path, handle] : open_devices_) {
          CloseHandle(handle);
      }
      open_devices_.clear();
      result->Success();
  } else if (method_call.method_name().compare("enumerate") == 0) {
      flutter::EncodableList devices = GetDeviceList();
      result->Success(flutter::EncodableValue(devices));
      
  } else if (method_call.method_name().compare("open") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (!args) { result->Error("INVALID_ARGUMENT", "Arguments missing"); return; }
      
      auto path_it = args->find(flutter::EncodableValue("path"));
      if (path_it == args->end()) { result->Error("INVALID_ARGUMENT", "Path missing"); return; }
      std::string path = std::get<std::string>(path_it->second);
      
      HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
      
      if (handle == INVALID_HANDLE_VALUE) {
          DWORD errorCode = GetLastError();
          std::string message = "Failed to open device (Error: " + std::to_string(errorCode) + ")";
          std::string code = "OPEN_FAILED";

          if (errorCode == ERROR_ACCESS_DENIED) {
              code = "PERMISSION_DENIED";
              message = "Access denied. The device might be a system device (keyboard/mouse) or already opened without shared access.";
          } else if (errorCode == ERROR_SHARING_VIOLATION) {
              code = "SHARING_VIOLATION";
              message = "Sharing violation. The device is already open by another process with exclusive access.";
          } else if (errorCode == ERROR_FILE_NOT_FOUND) {
              code = "NOT_FOUND";
              message = "Device path not found.";
          }

          result->Error(code, message, flutter::EncodableValue((int)errorCode));
          return;
      }
      
      open_devices_[path] = handle;
      
      // Return device info again
      HIDD_ATTRIBUTES attributes;
      attributes.Size = sizeof(HIDD_ATTRIBUTES);
      HidD_GetAttributes(handle, &attributes);
      
      PHIDP_PREPARSED_DATA preparsedData;
      HIDP_CAPS caps = {};
      if (HidD_GetPreparsedData(handle, &preparsedData)) {
          HidP_GetCaps(preparsedData, &caps);
          preparsed_data_[path] = preparsedData;
          device_caps_[path] = caps;
      } else {
          // If we can't get caps, we still have the device but features might fail
          // ignore the error for now as enumeration found it
      }
      
      // Setup event channel
      std::string channel_name = "hid_api/reports/" + path;
      auto event_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger_, channel_name, &flutter::StandardMethodCodec::GetInstance());
      
      auto handler = std::make_unique<ReportStreamHandler>(handle);
      
      // Setup disconnection channel
      std::string disc_channel_name = "hid_api/disconnection/" + path;
      auto disc_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger_, disc_channel_name, &flutter::StandardMethodCodec::GetInstance());
      auto disc_handler = std::make_unique<DisconnectionStreamHandler>();
      handler->SetDisconnectionHandler(disc_handler.get());
      disc_channel->SetStreamHandler(std::move(disc_handler));
      disconnection_channels_[path] = std::move(disc_channel);

      event_channel->SetStreamHandler(std::move(handler));
      event_channels_[path] = std::move(event_channel);

      wchar_t buffer[126];
      std::string manufacturer = "";
      std::string product = "";
      std::string serial = "";
      
      if (HidD_GetManufacturerString(handle, buffer, sizeof(buffer))) manufacturer = WStringToString(buffer);
      if (HidD_GetProductString(handle, buffer, sizeof(buffer))) product = WStringToString(buffer);
      if (HidD_GetSerialNumberString(handle, buffer, sizeof(buffer))) serial = WStringToString(buffer);

      flutter::EncodableMap deviceMap;
      deviceMap[flutter::EncodableValue("path")] = flutter::EncodableValue(path);
      deviceMap[flutter::EncodableValue("vendorId")] = flutter::EncodableValue((int)attributes.VendorID);
      deviceMap[flutter::EncodableValue("productId")] = flutter::EncodableValue((int)attributes.ProductID);
      deviceMap[flutter::EncodableValue("releaseNumber")] = flutter::EncodableValue((int)attributes.VersionNumber);
      deviceMap[flutter::EncodableValue("usagePage")] = flutter::EncodableValue((int)caps.UsagePage);
      deviceMap[flutter::EncodableValue("usage")] = flutter::EncodableValue((int)caps.Usage);
      deviceMap[flutter::EncodableValue("manufacturer")] = flutter::EncodableValue(manufacturer);
      deviceMap[flutter::EncodableValue("product")] = flutter::EncodableValue(product);
      deviceMap[flutter::EncodableValue("serialNumber")] = flutter::EncodableValue(serial);
      deviceMap[flutter::EncodableValue("interfaceNumber")] = flutter::EncodableValue(ParseInterfaceNumber(path));
      
      result->Success(flutter::EncodableValue(deviceMap));

  } else if (method_call.method_name().compare("close") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      std::string path = std::get<std::string>(args->find(flutter::EncodableValue("path"))->second);
      
      if (open_devices_.count(path)) {
          CloseHandle(open_devices_[path]);
          if (preparsed_data_.count(path)) {
              HidD_FreePreparsedData(preparsed_data_[path]);
              preparsed_data_.erase(path);
          }
          device_caps_.erase(path);
          open_devices_.erase(path);
          event_channels_.erase(path);
          disconnection_channels_.erase(path);
      }
      result->Success();

  } else if (method_call.method_name().compare("read") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      std::string path = std::get<std::string>(args->find(flutter::EncodableValue("path"))->second);
      
      if (open_devices_.count(path)) {
          HANDLE handle = open_devices_[path];
          std::vector<uint8_t> buffer(65); 
          DWORD bytesRead = 0;
          
          OVERLAPPED ol = {0};
          ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
          
          if (!ReadFile(handle, buffer.data(), (DWORD)buffer.size(), &bytesRead, &ol)) {
              if (GetLastError() == ERROR_IO_PENDING) {
                  WaitForSingleObject(ol.hEvent, 1000); 
                  GetOverlappedResult(handle, &ol, &bytesRead, FALSE);
              }
          }
          CloseHandle(ol.hEvent);
          
          if (bytesRead > 0) {
              std::vector<uint8_t> data(buffer.begin(), buffer.begin() + bytesRead);
              flutter::EncodableMap result_map;
              result_map[flutter::EncodableValue("data")] = flutter::EncodableValue(data);
              result_map[flutter::EncodableValue("reportId")] = flutter::EncodableValue((int)buffer[0]); 
              result->Success(flutter::EncodableValue(result_map));
          } else {
              result->Error("READ_FAILED", "No data read or read failed: " + GetLastErrorAsString(), flutter::EncodableValue((int)GetLastError()));
          }
      } else {
          result->Error("DEVICE_CLOSED", "Device not open");
      }
      
  } else if (method_call.method_name().compare("sendReport") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (!args) { result->Error("INVALID_ARGUMENT", "Arguments missing"); return; }
      
      auto path_it = args->find(flutter::EncodableValue("path"));
      auto data_it = args->find(flutter::EncodableValue("data"));
      auto type_it = args->find(flutter::EncodableValue("type"));
      
      if (path_it == args->end() || data_it == args->end() || type_it == args->end()) {
          result->Error("INVALID_ARGUMENT", "Missing required arguments");
          return;
      }
      
      std::string path = std::get<std::string>(path_it->second);
      std::vector<uint8_t> data = std::get<std::vector<uint8_t>>(data_it->second);
      std::string type_str = std::get<std::string>(type_it->second);
      
      auto report_id_it = args->find(flutter::EncodableValue("reportId"));
      int report_id = (report_id_it != args->end()) ? std::get<int>(report_id_it->second) : 0;
      
      bool is_output = (type_str == "output");
      std::string report_type_name = is_output ? "Output Report" : "Feature Report";

      if (!open_devices_.count(path)) {
          result->Error("DEVICE_CLOSED", "Device not open");
          return;
      }
      
      HANDLE handle = open_devices_[path];
      
      // Determine the required buffer size based on report type
      size_t required_size = data.size() + 1;
      if (device_caps_.count(path)) {
          required_size = is_output 
              ? device_caps_[path].OutputReportByteLength
              : device_caps_[path].FeatureReportByteLength;
      }
      
      // Create buffer with the correct size and initialize to zero
      std::vector<uint8_t> buffer(required_size, 0);
      buffer[0] = (uint8_t)report_id;
      
      // Copy data into buffer after the report id
      size_t copy_len = (std::min)(data.size(), buffer.size() - 1);
      std::copy(data.begin(), data.begin() + copy_len, buffer.begin() + 1);
      
      bool success = false;
      DWORD error_code = 0;
      
      if (is_output) {
          // Send Output Report using WriteFile
          OVERLAPPED ol = {0};
          ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
          
          DWORD bytesWritten = 0;
          if (WriteFile(handle, buffer.data(), (DWORD)buffer.size(), &bytesWritten, &ol)) {
              // Synchronous completion
              success = true;
          } else if (GetLastError() == ERROR_IO_PENDING) {
              // Wait for async operation to complete
              if (WaitForSingleObject(ol.hEvent, 1000) == WAIT_OBJECT_0) {
                  if (GetOverlappedResult(handle, &ol, &bytesWritten, FALSE)) {
                      success = (bytesWritten > 0);
                  } else {
                      error_code = GetLastError();
                  }
              } else {
                  // Timeout
                  CancelIo(handle);
                  error_code = GetLastError();
              }
          } else {
              error_code = GetLastError();
          }
          CloseHandle(ol.hEvent);
      } else {
          // Send Feature Report using HidD_SetFeature
          success = HidD_SetFeature(handle, buffer.data(), (ULONG)buffer.size());
          if (!success) {
              error_code = GetLastError();
          }
      }
      
      if (success) {
          // Return the actual data length sent (not including report ID or padding)
          result->Success(flutter::EncodableValue((int)data.size()));
      } else {
          std::string error_msg = "Send " + report_type_name + " failed: " + GetLastErrorAsString();
          result->Error("WRITE_FAILED", error_msg, flutter::EncodableValue((int)error_code));
      }
  } else if (method_call.method_name().compare("getFeatureReport") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      std::string path = std::get<std::string>(args->find(flutter::EncodableValue("path"))->second);
      int length = std::get<int>(args->find(flutter::EncodableValue("length"))->second);
      
      auto report_id_it = args->find(flutter::EncodableValue("reportId"));
      int report_id = (report_id_it != args->end()) ? std::get<int>(report_id_it->second) : 0;

      if (open_devices_.count(path)) {
          HANDLE handle = open_devices_[path];
          
          size_t required_size = length + 1;
          if (device_caps_.count(path)) {
              required_size = device_caps_[path].FeatureReportByteLength;
          }

          std::vector<uint8_t> buffer(required_size, 0);
          buffer[0] = (uint8_t)report_id;

          if (HidD_GetFeature(handle, buffer.data(), (ULONG)buffer.size())) {
              flutter::EncodableMap result_map;
              result_map[flutter::EncodableValue("data")] = flutter::EncodableValue(buffer);
              // Note: Dart side expects 'data' containing the full buffer including the ID.
              result->Success(flutter::EncodableValue(result_map));
          } else {
              result->Error("READ_FAILED", "Get Feature Report failed: " + GetLastErrorAsString(), flutter::EncodableValue((int)GetLastError()));
          }
      } else {
          result->Error("DEVICE_CLOSED", "Device not open");
      }
  } else {
    result->NotImplemented();
  }
}

}  // namespace hid_api
