#include "include/hid_api_linux/hid_api_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <hidapi/hidapi.h>
#include <algorithm>
#include <sstream>
#include <map>
#include <string>
#include <thread>
#include <vector>
#include <mutex>
#include <atomic>
#include <cerrno>
#include <cstdint>
#include <cwchar>
#include <cstring>
#include <unistd.h>

#define HID_API_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), hid_api_plugin_get_type(), \
                               HidApiPlugin))

struct DeviceUpdateState;

struct _HidApiPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* method_channel;
  FlEventChannel* device_update_channel;
  DeviceUpdateState* device_update_state;
};

G_DEFINE_TYPE(HidApiPlugin, hid_api_plugin, g_object_get_type())

// Helper to convert wchar_t* to std::string (UTF-8)
static std::string wchar_to_utf8(const wchar_t* wstr) {
    if (!wstr) return "";
    std::mbstate_t state = std::mbstate_t();
    std::size_t len = std::wcsrtombs(nullptr, &wstr, 0, &state);
    if (len == static_cast<std::size_t>(-1)) return "";
    std::vector<char> mbstr(len + 1);
    std::wcsrtombs(&mbstr[0], &wstr, len, &state);
    return std::string(&mbstr[0]);
}

static FlValue* create_device_info_map(const hid_device_info* device) {
    FlValue* map = fl_value_new_map();
    fl_value_set_string_take(map, "path", fl_value_new_string(device->path ? device->path : ""));
    fl_value_set_string_take(map, "vendorId", fl_value_new_int(device->vendor_id));
    fl_value_set_string_take(map, "productId", fl_value_new_int(device->product_id));
    fl_value_set_string_take(map, "releaseNumber", fl_value_new_int(device->release_number));
    fl_value_set_string_take(map, "usagePage", fl_value_new_int(device->usage_page));
    fl_value_set_string_take(map, "usage", fl_value_new_int(device->usage));
    fl_value_set_string_take(map, "interfaceNumber", fl_value_new_int(device->interface_number));

    std::string manufacturer = wchar_to_utf8(device->manufacturer_string);
    std::string product = wchar_to_utf8(device->product_string);
    std::string serial_number = wchar_to_utf8(device->serial_number);
    fl_value_set_string_take(map, "manufacturer", fl_value_new_string(manufacturer.c_str()));
    fl_value_set_string_take(map, "product", fl_value_new_string(product.c_str()));
    fl_value_set_string_take(map, "serialNumber", fl_value_new_string(serial_number.c_str()));
    return map;
}

static FlValue* create_device_info_list(int vendor_id = 0, int product_id = 0) {
    FlValue* result_list = fl_value_new_list();
    struct hid_device_info* devices = hid_enumerate(vendor_id, product_id);

    for (struct hid_device_info* current = devices; current; current = current->next) {
        fl_value_append_take(result_list, create_device_info_map(current));
    }

    hid_free_enumeration(devices);
    return result_list;
}

static FlValue* create_device_info_map_for_path(const char* path) {
    if (!path) return nullptr;

    struct hid_device_info* devices = hid_enumerate(0, 0);
    FlValue* result_map = nullptr;

    for (struct hid_device_info* current = devices; current; current = current->next) {
        if (current->path && std::string(current->path) == std::string(path)) {
            result_map = create_device_info_map(current);
            break;
        }
    }

    hid_free_enumeration(devices);
    return result_map;
}

static FlMethodResponse* create_open_failure_response(const char* path) {
    errno = 0;
    if (access(path, F_OK) != 0) {
        int error_number = errno;
        std::string message = "HID device path not found: " + std::string(path);
        if (error_number != 0) {
            message += " (" + std::string(std::strerror(error_number)) + ")";
        }
        return FL_METHOD_RESPONSE(fl_method_error_response_new(
            "DEVICE_NOT_FOUND",
            message.c_str(),
            fl_value_new_int(error_number)));
    }

    errno = 0;
    if (access(path, R_OK | W_OK) != 0) {
        int error_number = errno;
        std::string message = "Permission denied opening HID device " + std::string(path) +
            ". Add a udev rule or run with permissions that can read and write this hidraw device.";
        if (error_number != 0) {
            message += " (" + std::string(std::strerror(error_number)) + ")";
        }
        return FL_METHOD_RESPONSE(fl_method_error_response_new(
            "PERMISSION_DENIED",
            message.c_str(),
            fl_value_new_int(error_number)));
    }

    std::string message = "Failed to open HID device " + std::string(path) +
        ". The device may have disappeared or may not allow read/write hidraw access.";
    return FL_METHOD_RESPONSE(fl_method_error_response_new("OPEN_FAILED", message.c_str(), nullptr));
}

static std::string device_list_signature() {
    std::vector<std::string> entries;
    struct hid_device_info* devices = hid_enumerate(0, 0);

    for (struct hid_device_info* current = devices; current; current = current->next) {
        std::ostringstream entry;
        entry << (current->path ? current->path : "")
              << "|" << current->vendor_id
              << "|" << current->product_id
              << "|" << current->release_number
              << "|" << current->usage_page
              << "|" << current->usage
              << "|" << current->interface_number
              << "|" << wchar_to_utf8(current->serial_number);
        entries.push_back(entry.str());
    }

    hid_free_enumeration(devices);
    std::sort(entries.begin(), entries.end());

    std::ostringstream signature;
    for (const std::string& entry : entries) {
        signature << entry << "\n";
    }
    return signature.str();
}

// Device state management
struct DeviceState {
    hid_device* device;
    FlEventChannel* event_channel;
    FlEventChannel* disconnection_channel;
    std::thread* read_thread;
    std::atomic<bool> reading;
    std::atomic<bool> disconnected;
    std::string path;
};

static std::map<std::string, DeviceState*> open_devices;
static std::mutex devices_mutex;

struct DeviceUpdateState {
    FlEventChannel* channel;
    guint poll_source_id;
    bool listening;
    std::string last_signature;
};

static void send_device_update(DeviceUpdateState* state) {
    if (!state || !state->channel || !state->listening) return;

    g_autoptr(FlValue) devices = create_device_info_list();
    fl_event_channel_send(state->channel, devices, nullptr, nullptr);
}

static gboolean device_update_poll_cb(gpointer user_data) {
    DeviceUpdateState* state = static_cast<DeviceUpdateState*>(user_data);
    if (!state || !state->listening) {
        if (state) state->poll_source_id = 0;
        return G_SOURCE_REMOVE;
    }

    std::string signature = device_list_signature();
    if (signature != state->last_signature) {
        state->last_signature = signature;
        send_device_update(state);
    }

    return G_SOURCE_CONTINUE;
}

static void stop_device_update_stream(DeviceUpdateState* state) {
    if (!state) return;

    state->listening = false;
    state->last_signature.clear();
    if (state->poll_source_id != 0) {
        g_source_remove(state->poll_source_id);
        state->poll_source_id = 0;
    }
}

static void send_disconnection_event(DeviceState* state) {
    if (!state || !state->disconnection_channel) return;
    if (state->disconnected.exchange(true)) return;

    struct DisconnectionData {
        FlEventChannel* channel;
    };

    DisconnectionData* data = new DisconnectionData();
    data->channel = FL_EVENT_CHANNEL(g_object_ref(state->disconnection_channel));

    g_idle_add([](gpointer user_data) -> gboolean {
        DisconnectionData* data = static_cast<DisconnectionData*>(user_data);
        g_autoptr(FlValue) event = fl_value_new_null();
        fl_event_channel_send(data->channel, event, nullptr, nullptr);
        g_object_unref(data->channel);
        delete data;
        return G_SOURCE_REMOVE;
    }, data);
}

static void send_report_event(DeviceState* state, const uint8_t* data, size_t length) {
    if (!state->event_channel) return;
    
    // We are on a background thread, need to post to main thread
    struct ReportData {
        FlEventChannel* channel;
        uint8_t* data;
        size_t length;
    };
    
    ReportData* rdata = new ReportData();
    rdata->channel = FL_EVENT_CHANNEL(g_object_ref(state->event_channel));
    rdata->length = length;
    rdata->data = new uint8_t[length];
    memcpy(rdata->data, data, length);
    
    g_idle_add([](gpointer user_data) -> gboolean {
        ReportData* r = static_cast<ReportData*>(user_data);
        g_autoptr(FlValue) map = fl_value_new_map();
        // hid_api expects 'reportId' (int) and 'data' (Uint8List)
        // If the first byte is report ID (in some modes), hidapi usually handles it.
        // But hid_read returns the data. If the device uses numbered reports, the first byte IS the report ID.
        // The Dart side wrapper `MethodChannelHidDevice` wraps it.
        // It expects {reportId: int, data: Uint8List}.
        // Often hidapi returns report ID mainly if it's non-zero.
        // We will pass 0 for reportId if we can't easily distinguish, or parse the first byte if length > 0.
        // BUT, for now let's just pass data and let Dart handle parsing if needed, 
        // OR follow the iOS/Mac implementation pattern. 
        // Mac implementation often separates them. HIDAPI `hid_read` puts report ID in first byte if numbered reports are used.
        
        // Let's create the map.
        fl_value_set_string_take(map, "reportId", fl_value_new_int(0)); // Default 0
        fl_value_set_string_take(map, "data", fl_value_new_uint8_list(r->data, r->length));
        
        fl_event_channel_send(r->channel, map, nullptr, nullptr);
        
        g_object_unref(r->channel);
        delete[] r->data;
        delete r;
        return G_SOURCE_REMOVE;
    }, rdata);
}

static void read_thread_func(DeviceState* state) {
    while (state->reading) {
        uint8_t buf[4096];
        // Blocking read with a small timeout to allow checking 'reading' flag
        int res = hid_read_timeout(state->device, buf, sizeof(buf), 100);
        
        if (res > 0) {
            send_report_event(state, buf, res);
        } else if (res < 0) {
            send_disconnection_event(state);
            state->reading = false;
        }
    }
}

// Method implementations

static FlMethodResponse* enumerate_devices(FlValue* args) {
    int vendor_id = 0;
    int product_id = 0;
    
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
         FlValue* v = fl_value_lookup_string(args, "vendorId");
         if (v && fl_value_get_type(v) == FL_VALUE_TYPE_INT) vendor_id = fl_value_get_int(v);
         
         FlValue* p = fl_value_lookup_string(args, "productId");
         if (p && fl_value_get_type(p) == FL_VALUE_TYPE_INT) product_id = fl_value_get_int(p);
    }
    
    g_autoptr(FlValue) result_list = create_device_info_list(vendor_id, product_id);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_list));
}

static FlMethodResponse* open_device(HidApiPlugin* self, FlValue* args) {
    const char* path = nullptr;
    bool exclusive = false;
    if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* v = fl_value_lookup_string(args, "path");
        if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) path = fl_value_get_string(v);
        FlValue* exclusive_value = fl_value_lookup_string(args, "exclusive");
        if (exclusive_value && fl_value_get_type(exclusive_value) == FL_VALUE_TYPE_BOOL) {
            exclusive = fl_value_get_bool(exclusive_value);
        }
    }
    
    if (!path) return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENT", "Path is required", nullptr));
    (void)exclusive; // hidapi on Linux does not expose an exclusive-open mode here.

    std::lock_guard<std::mutex> lock(devices_mutex);
    if (open_devices.find(path) != open_devices.end()) {
        g_autoptr(FlValue) existing_info = create_device_info_map_for_path(path);
        if (existing_info) {
            return FL_METHOD_RESPONSE(fl_method_success_response_new(existing_info));
        }
        return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "Device is open but no longer enumerates", nullptr));
    }

    hid_device* handle = hid_open_path(path);
    if (!handle) {
        return create_open_failure_response(path);
    }
    
    DeviceState* state = new DeviceState();
    state->device = handle;
    state->event_channel = nullptr;
    state->disconnection_channel = nullptr;
    state->path = path;
    state->reading = false;
    state->disconnected = false;
    state->read_thread = nullptr;
    
    // Register event channel
    g_autofree gchar* channel_name = g_strdup_printf("hid_api/reports/%s", path);
    g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
    state->event_channel = fl_event_channel_new(fl_plugin_registrar_get_messenger(self->registrar),
                                                channel_name,
                                                FL_METHOD_CODEC(codec));
                                                
    // Define stream handlers
    auto listen_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
        DeviceState* s = static_cast<DeviceState*>(user_data);
        if (!s->reading) {
            s->reading = true;
            s->read_thread = new std::thread(read_thread_func, s);
        }
        return nullptr;
    };
    
    auto cancel_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
        DeviceState* s = static_cast<DeviceState*>(user_data);
        if (s->reading) {
            s->reading = false;
            if (s->read_thread && s->read_thread->joinable()) {
                s->read_thread->join();
                delete s->read_thread;
                s->read_thread = nullptr;
            }
        }
        return nullptr;
    };

    fl_event_channel_set_stream_handlers(state->event_channel, listen_handler, cancel_handler, state, nullptr);

    g_autofree gchar* disconnection_channel_name = g_strdup_printf("hid_api/disconnection/%s", path);
    g_autoptr(FlStandardMethodCodec) disconnection_codec = fl_standard_method_codec_new();
    state->disconnection_channel =
        fl_event_channel_new(fl_plugin_registrar_get_messenger(self->registrar),
                             disconnection_channel_name,
                             FL_METHOD_CODEC(disconnection_codec));

    auto disconnection_listen_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
        return nullptr;
    };

    auto disconnection_cancel_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
        return nullptr;
    };

    fl_event_channel_set_stream_handlers(state->disconnection_channel,
                                         disconnection_listen_handler,
                                         disconnection_cancel_handler,
                                         state,
                                         nullptr);

	    FlValue* result_map = create_device_info_map_for_path(path);
    
    if (!result_map) {
        g_clear_object(&state->event_channel);
        g_clear_object(&state->disconnection_channel);
        hid_close(handle);
        delete state;
        return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "Opened device, but could not enumerate device info", nullptr));
    }

    open_devices[path] = state;
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));
}

static FlMethodResponse* close_device(FlValue* args) {
     const char* path = nullptr;
    if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* v = fl_value_lookup_string(args, "path");
        if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) path = fl_value_get_string(v);
    }
    
    if (path) {
         std::lock_guard<std::mutex> lock(devices_mutex);
         auto it = open_devices.find(path);
         if (it != open_devices.end()) {
             DeviceState* s = it->second;
             s->reading = false;
	             if (s->read_thread && s->read_thread->joinable()) {
	                 s->read_thread->join();
	                 delete s->read_thread;
	             }
	             hid_close(s->device);
	             g_clear_object(&s->event_channel);
	             g_clear_object(&s->disconnection_channel);
	             delete s;
	             open_devices.erase(it);
	         }
    }
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
}

static FlMethodResponse* read_device(FlValue* args) {
     const char* path = nullptr;
     int timeout = -1;
     
     if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* v = fl_value_lookup_string(args, "path");
        if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) path = fl_value_get_string(v);
        FlValue* t = fl_value_lookup_string(args, "timeout");
        if (t && fl_value_get_type(t) == FL_VALUE_TYPE_INT) timeout = fl_value_get_int(t);
    }
    
    hid_device* dev = nullptr;
    {
         std::lock_guard<std::mutex> lock(devices_mutex);
         auto it = open_devices.find(path ? path : "");
         if (it != open_devices.end()) dev = it->second->device;
    }
    
    if (!dev) return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "Device not open", nullptr));
    
    uint8_t buf[4096];
    int res = hid_read_timeout(dev, buf, sizeof(buf), timeout >= 0 ? timeout : 0);
    
    if (res < 0) {
        std::lock_guard<std::mutex> lock(devices_mutex);
        auto it = open_devices.find(path ? path : "");
        if (it != open_devices.end()) send_disconnection_event(it->second);
        return FL_METHOD_RESPONSE(fl_method_error_response_new("READ_FAILED", "Read failed", nullptr));
    }
    
    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string_take(map, "reportId", fl_value_new_int(0));
    fl_value_set_string_take(map, "data", fl_value_new_uint8_list(buf, res)); // res could be 0, valid
    
    return FL_METHOD_RESPONSE(fl_method_success_response_new(map));
}

static FlMethodResponse* write_device(FlValue* args) {
     const char* path = nullptr;
     uint8_t* data = nullptr;
     size_t data_len = 0;
     int report_id = 0;
     const char* type_str = "output";
     
     if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* v = fl_value_lookup_string(args, "path");
        if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) path = fl_value_get_string(v);
        
        FlValue* r = fl_value_lookup_string(args, "reportId");
        if (r && fl_value_get_type(r) == FL_VALUE_TYPE_INT) report_id = fl_value_get_int(r);
        
        FlValue* d = fl_value_lookup_string(args, "data");
        if (d && fl_value_get_type(d) == FL_VALUE_TYPE_UINT8_LIST) {
             data = (uint8_t*)fl_value_get_uint8_list(d);
             data_len = fl_value_get_length(d);
        }
        
        FlValue* t = fl_value_lookup_string(args, "type");
        if (t && fl_value_get_type(t) == FL_VALUE_TYPE_STRING) type_str = fl_value_get_string(t);
    }
    
    hid_device* dev = nullptr;
    {
         std::lock_guard<std::mutex> lock(devices_mutex);
         auto it = open_devices.find(path ? path : "");
         if (it != open_devices.end()) dev = it->second->device;
    }
    
    if (!dev) return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "Device not open", nullptr));
    
    // Construct buffer: if reportId specified and needed, usually first byte.
    // hid_write sends output report. data usually includes report ID if using numbered reports.
    // Dart side: sendReport(reportId, data).
    // If reportId is set in Dart, we might need to prepend it if 'data' doesn't have it?
    // Usually Dart wrapper prepends or assumes data has it?
    // Let's assume data provided is what to maintain.
    // BUT the 'reportId' param in invocation suggests we might need to handle it.
    // Standard HIDAPI usage: if report ID used, buffer[0] = report_id.
    // If Dart wrapper passes them separate, we must merge.
    
    std::vector<uint8_t> buf;
    if (report_id != 0) {
        buf.push_back(report_id);
    }
    if (data) {
        buf.insert(buf.end(), data, data + data_len);
    }
    
    int res = -1;
    if (strcmp(type_str, "feature") == 0) {
        res = hid_send_feature_report(dev, buf.data(), buf.size());
    } else {
        res = hid_write(dev, buf.data(), buf.size());
    }
    
    if (res < 0) {
         // const wchar_t* err = hid_error(dev);
         return FL_METHOD_RESPONSE(fl_method_error_response_new("WRITE_FAILED", "Write failed", nullptr));
    }
    
    return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_int(res)));
}

static FlMethodResponse* set_blocking(FlValue* args) {
    const char* path = nullptr;
    bool blocking = true;
     if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* v = fl_value_lookup_string(args, "path");
        if (v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) path = fl_value_get_string(v);
        FlValue* b = fl_value_lookup_string(args, "blocking");
        if (b && fl_value_get_type(b) == FL_VALUE_TYPE_BOOL) blocking = fl_value_get_bool(b);
    }
    
    hid_device* dev = nullptr;
    {
         std::lock_guard<std::mutex> lock(devices_mutex);
         auto it = open_devices.find(path ? path : "");
         if (it != open_devices.end()) dev = it->second->device;
    }
    if(dev) {
        hid_set_nonblocking(dev, blocking ? 0 : 1);
        return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    }
    return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "", nullptr));
}

static FlMethodResponse* get_feature_report(FlValue* args) {
    const char* path = nullptr;
    int report_id = 0;
    int length = 0;

    if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
        FlValue* path_value = fl_value_lookup_string(args, "path");
        if (path_value && fl_value_get_type(path_value) == FL_VALUE_TYPE_STRING) {
            path = fl_value_get_string(path_value);
        }

        FlValue* report_id_value = fl_value_lookup_string(args, "reportId");
        if (report_id_value && fl_value_get_type(report_id_value) == FL_VALUE_TYPE_INT) {
            report_id = fl_value_get_int(report_id_value);
        }

        FlValue* length_value = fl_value_lookup_string(args, "length");
        if (length_value && fl_value_get_type(length_value) == FL_VALUE_TYPE_INT) {
            length = fl_value_get_int(length_value);
        }
    }

    if (!path || length <= 0) {
        return FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGUMENT", "Path and positive length are required", nullptr));
    }

    hid_device* device = nullptr;
    {
        std::lock_guard<std::mutex> lock(devices_mutex);
        auto it = open_devices.find(path);
        if (it != open_devices.end()) device = it->second->device;
    }

    if (!device) {
        return FL_METHOD_RESPONSE(fl_method_error_response_new("DEVICE_NOT_FOUND", "Device not open", nullptr));
    }

    std::vector<uint8_t> buffer(static_cast<size_t>(length), 0);
    buffer[0] = static_cast<uint8_t>(report_id);

    int result = hid_get_feature_report(device, buffer.data(), buffer.size());
    if (result < 0) {
        return FL_METHOD_RESPONSE(fl_method_error_response_new("READ_FAILED", "Get feature report failed", nullptr));
    }

    g_autoptr(FlValue) result_map = fl_value_new_map();
    fl_value_set_string_take(result_map, "data", fl_value_new_uint8_list(buffer.data(), result));
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_map));
}

static void hid_api_plugin_handle_method_call(
    HidApiPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("Linux")));
  } else if (strcmp(method, "initialize") == 0) {
      hid_init();
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "shutdown") == 0) {
      stop_device_update_stream(self->device_update_state);
      // close all first?
      hid_exit();
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else if (strcmp(method, "enumerate") == 0) {
      response = enumerate_devices(args);
  } else if (strcmp(method, "open") == 0) {
      response = open_device(self, args);
  } else if (strcmp(method, "close") == 0) {
      response = close_device(args);
  } else if (strcmp(method, "read") == 0) {
      response = read_device(args);
  } else if (strcmp(method, "sendReport") == 0) { // method name from MethodChannelHidDevice: sendReport
      response = write_device(args);
  } else if (strcmp(method, "setBlocking") == 0) {
      response = set_blocking(args);
  } else if (strcmp(method, "getFeatureReport") == 0) {
      response = get_feature_report(args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void hid_api_plugin_dispose(GObject* object) {
  HidApiPlugin* self = HID_API_PLUGIN(object);
  stop_device_update_stream(self->device_update_state);
  delete self->device_update_state;
  self->device_update_state = nullptr;
  g_clear_object(&self->device_update_channel);

  G_OBJECT_CLASS(hid_api_plugin_parent_class)->dispose(object);
}

static void hid_api_plugin_class_init(HidApiPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = hid_api_plugin_dispose;
}

static void hid_api_plugin_init(HidApiPlugin* self) {
  self->registrar = nullptr;
  self->method_channel = nullptr;
  self->device_update_channel = nullptr;
  self->device_update_state = nullptr;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  HidApiPlugin* plugin = HID_API_PLUGIN(user_data);
  hid_api_plugin_handle_method_call(plugin, method_call);
}

void hid_api_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  HidApiPlugin* plugin = HID_API_PLUGIN(
      g_object_new(hid_api_plugin_get_type(), nullptr));
  
  plugin->registrar = registrar; // store for dynamic channels
  
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->method_channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "hid_api",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(plugin->method_channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin->device_update_state = new DeviceUpdateState();
  plugin->device_update_state->channel = nullptr;
  plugin->device_update_state->poll_source_id = 0;
  plugin->device_update_state->listening = false;

  g_autoptr(FlStandardMethodCodec) event_codec = fl_standard_method_codec_new();
  plugin->device_update_channel =
      fl_event_channel_new(fl_plugin_registrar_get_messenger(registrar),
                           "hid_api/device_updates",
                           FL_METHOD_CODEC(event_codec));

  auto listen_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
      DeviceUpdateState* state = static_cast<DeviceUpdateState*>(user_data);
      hid_init();
      state->channel = channel;
      state->listening = true;
      state->last_signature = device_list_signature();
      send_device_update(state);

      if (state->poll_source_id == 0) {
          state->poll_source_id = g_timeout_add(1000, device_update_poll_cb, state);
      }
      return nullptr;
  };

  auto cancel_handler = [](FlEventChannel* channel, FlValue* args, gpointer user_data) -> FlMethodErrorResponse* {
      DeviceUpdateState* state = static_cast<DeviceUpdateState*>(user_data);
      stop_device_update_stream(state);
      return nullptr;
  };

  fl_event_channel_set_stream_handlers(plugin->device_update_channel,
                                       listen_handler,
                                       cancel_handler,
                                       plugin->device_update_state,
                                       nullptr);

  g_object_unref(plugin);
}
