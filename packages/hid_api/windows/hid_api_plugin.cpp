#include "hid_api_plugin.h"

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

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListen(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events) override {
    events_ = std::move(events);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancel(
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

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListen(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events) override {
    events_ = std::move(events);
    running_ = true;
    thread_ = std::thread(&ReportStreamHandler::ReadLoop, this);
    return nullptr;
  }

  void SetDisconnectionHandler(DisconnectionStreamHandler* handler) {
    disconnection_handler_ = handler;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancel(
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
        if (!ReadFile(device_, buffer.data(), (DWORD)buffer.size(), NULL, &ol)) {
            if (GetLastError() == ERROR_IO_PENDING) {
                if (WaitForSingleObject(ol.hEvent, 100) == WAIT_TIMEOUT) {
                    continue;
                }
                if (!GetOverlappedResult(device_, &ol, &bytesRead, FALSE)) {
                    if (GetLastError() == ERROR_DEVICE_NOT_CONNECTED || GetLastError() == ERROR_GEN_FAILURE) {
                        if (disconnection_handler_) disconnection_handler_->Notify();
                        running_ = false;
                    }
                }
            } else if (GetLastError() == ERROR_DEVICE_NOT_CONNECTED || GetLastError() == ERROR_GEN_FAILURE) {
                if (disconnection_handler_) disconnection_handler_->Notify();
                running_ = false;
            }
        } else {
            GetOverlappedResult(device_, &ol, &bytesRead, FALSE);
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

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListen(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events) override {
    events_ = std::move(events);
    running_ = true;
    thread_ = std::thread(&DeviceUpdateStreamHandler::WatchLoop, this);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancel(
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
    while (running_) {
        // Polling as a simple implementation for notifications
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
    open_devices_.clear();
}

std::string WStringToString(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, NULL, NULL);
    return strTo;
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
      GUID hidGuid;
      HidD_GetHidGuid(&hidGuid);
      
      HDEVINFO deviceInfoList = SetupDiGetClassDevs(&hidGuid, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
      if (deviceInfoList == INVALID_HANDLE_VALUE) {
          result->Error("ENUMERATE_FAILED", "Failed to get device list");
          return;
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
                          deviceMap[flutter::EncodableValue("interfaceNumber")] = flutter::EncodableValue(0);
                          
                          devices.push_back(flutter::EncodableValue(deviceMap));
                      }
                  }
                  CloseHandle(handle);
              }
          }
      }
      SetupDiDestroyDeviceInfoList(deviceInfoList);
      result->Success(flutter::EncodableValue(devices));
      
  } else if (method_call.method_name().compare("open") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      if (!args) { result->Error("INVALID_ARGUMENT", "Arguments missing"); return; }
      
      auto path_it = args->find(flutter::EncodableValue("path"));
      if (path_it == args->end()) { result->Error("INVALID_ARGUMENT", "Path missing"); return; }
      std::string path = std::get<std::string>(path_it->second);
      
      HANDLE handle = CreateFileA(path.c_str(), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
      
      if (handle == INVALID_HANDLE_VALUE) {
          result->Error("OPEN_FAILED", "Failed to open device");
          return;
      }
      
      open_devices_[path] = handle;
      
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

      // Return device info again
      HIDD_ATTRIBUTES attributes;
      attributes.Size = sizeof(HIDD_ATTRIBUTES);
      HidD_GetAttributes(handle, &attributes);
      
      PHIDP_PREPARSED_DATA preparsedData;
      HIDP_CAPS caps;
      HidD_GetPreparsedData(handle, &preparsedData);
      HidP_GetCaps(preparsedData, &caps);
      HidD_FreePreparsedData(preparsedData);
      
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
      deviceMap[flutter::EncodableValue("interfaceNumber")] = flutter::EncodableValue(0);
      
      result->Success(flutter::EncodableValue(deviceMap));

  } else if (method_call.method_name().compare("close") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      std::string path = std::get<std::string>(args->find(flutter::EncodableValue("path"))->second);
      
      if (open_devices_.count(path)) {
          CloseHandle(open_devices_[path]);
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
              result->Error("READ_FAILED", "No data read");
          }
      } else {
          result->Error("DEVICE_CLOSED", "Device not open");
      }
      
  } else if (method_call.method_name().compare("write") == 0) {
      const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
      std::string path = std::get<std::string>(args->find(flutter::EncodableValue("path"))->second);
      std::vector<uint8_t> data = std::get<std::vector<uint8_t>>(args->find(flutter::EncodableValue("data"))->second);
      
      if (open_devices_.count(path)) {
          HANDLE handle = open_devices_[path];
          
          OVERLAPPED ol = {0};
          ol.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
          
          DWORD bytesWritten = 0;
          if (!WriteFile(handle, data.data(), (DWORD)data.size(), &bytesWritten, &ol)) {
              if (GetLastError() == ERROR_IO_PENDING) {
                  WaitForSingleObject(ol.hEvent, 1000);
                  GetOverlappedResult(handle, &ol, &bytesWritten, FALSE);
              }
          }
          CloseHandle(ol.hEvent);
          
          result->Success(flutter::EncodableValue((int)bytesWritten));
      } else {
          result->Error("DEVICE_CLOSED", "Device not open");
      }
  } else {
    result->NotImplemented();
  }
}

}  // namespace hid_api
