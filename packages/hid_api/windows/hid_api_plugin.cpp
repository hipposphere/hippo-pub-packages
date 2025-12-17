#include "hid_api_plugin.h"

#include <windows.h>
#include <hidsdi.h>
#include <setupapi.h>
#include <initguid.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <vector>
#include <iostream>
#include <codecvt>

namespace hid_api {

// static
void HidApiPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "hid_api",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<HidApiPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

HidApiPlugin::HidApiPlugin() {}

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
              std::string path = deviceInterfaceDetailData->DevicePath;
              
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
          // Use WriteFile for Output reports usually, or HidD_SetOutputReport
          // WriteFile requires the first byte to be the Report ID.
          
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
