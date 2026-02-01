#include "include/hotkey_api/hotkey_api_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/extensions/XInput2.h>
#include <thread>
#include <atomic>
#include <iostream>

#define HOTKEY_API_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), hotkey_api_plugin_get_type(), \
                               HotkeyApiPlugin))

struct _HotkeyApiPlugin {
  GObject parent_instance;
  FlMethodChannel* method_channel;
  FlEventChannel* event_channel;
  std::thread* event_thread;
  std::atomic<bool> monitoring;
};

G_DEFINE_TYPE(HotkeyApiPlugin, hotkey_api_plugin, g_object_get_type())

static FlMethodErrorResponse* listen_stream(HotkeyApiPlugin* self,
                                            FlValue* args) {
  // Logic to start listening specific keys if needed, 
  // currently we listen all in the background thread when event channel attaches?
  return nullptr;
}

static FlMethodErrorResponse* cancel_stream(HotkeyApiPlugin* self,
                                            FlValue* args) {
  return nullptr;
}

// Struct to pass data to main thread
struct KeyEventData {
    HotkeyApiPlugin* plugin;
    int keycode;
    const char* type;
};

// Callback to send event on main thread
static gboolean send_event_on_main(gpointer user_data) {
    KeyEventData* data = static_cast<KeyEventData*>(user_data);
    if (!data->plugin->event_channel) {
        delete data;
        return G_SOURCE_REMOVE;
    }

    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string_take(map, "key", fl_value_new_int(data->keycode));
    fl_value_set_string_take(map, "type", fl_value_new_string(data->type));

    fl_event_channel_send(data->plugin->event_channel, map, nullptr, nullptr);

    delete data;
    return G_SOURCE_REMOVE;
}

static void monitor_thread_func(HotkeyApiPlugin* self) {
    Display* dpy = XOpenDisplay(NULL);
    if (!dpy) {
        std::cerr << "Failed to open X display for hotkey monitoring" << std::endl;
        return;
    }

    Window root = DefaultRootWindow(dpy);
    
    XIEventMask mask;
    unsigned char mask_bits[XIMaskLen(XI_LASTEVENT)] = {0};
    
    mask.deviceid = XIAllMasterDevices;
    mask.mask_len = sizeof(mask_bits);
    mask.mask = mask_bits;
    
    XISetMask(mask.mask, XI_KeyPress);
    XISetMask(mask.mask, XI_KeyRelease);
    
    XISelectEvents(dpy, root, &mask, 1);
    XSync(dpy, False);

    while (self->monitoring) {
        if (XPending(dpy) == 0) {
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            continue;
        }

        XEvent ev;
        XNextEvent(dpy, &ev);
        
        if (ev.xcookie.type == GenericEvent && ev.xcookie.extension == 131) { // 131 is usually XI2, but we should query opcode
             // Proper way:
             // int xi_opcode;
             // XQueryExtension(dpy, "XInputExtension", &xi_opcode, ...);
             // if (ev.xcookie.extension == xi_opcode)... but assumes constant for now or quick check.
             // Wait, XGetEventData IS needed.
        }
        
        // Actually, let's just query extension opcode first for robustness
        int xi_opcode, event, error;
        if (!XQueryExtension(dpy, "XInputExtension", &xi_opcode, &event, &error)) {
             break;
        }

        if (XGetEventData(dpy, &ev.xcookie)) {
            if (ev.xcookie.type == GenericEvent && ev.xcookie.extension == xi_opcode) {
                XIDeviceEvent* xiev = (XIDeviceEvent*)ev.xcookie.data;
                if (xiev->evtype == XI_KeyPress || xiev->evtype == XI_KeyRelease) {
                    KeyEventData* data = new KeyEventData();
                    data->plugin = self;
                    // For HotkeyEvent, we want linux keycode (X11 keycode).
                    // Flutter typically uses physical keys.
                    // X11 Keycode = Hardware Keycode + 8.
                    // Let's pass the raw X11 keycode and see if dart handles it.
                    data->keycode = xiev->detail; 
                    data->type = (xiev->evtype == XI_KeyPress) ? (xiev->flags & XIKeyRepeat ? "repeat" : "down") : "up";

                    g_idle_add(send_event_on_main, data);
               }
            }
            XFreeEventData(dpy, &ev.xcookie);
        }
    }

    XCloseDisplay(dpy);
}

static FlMethodErrorResponse* event_stream_listen(FlEventChannel* channel,
                                                  FlValue* args,
                                                  gpointer user_data) {
  HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(user_data);
  if (self->monitoring) return nullptr;

  self->monitoring = true;
  self->event_thread = new std::thread(monitor_thread_func, self);

  return nullptr;
}

static FlMethodErrorResponse* event_stream_cancel(FlEventChannel* channel,
                                                  FlValue* args,
                                                  gpointer user_data) {
  HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(user_data);
  if (self->monitoring) {
      self->monitoring = false;
      if (self->event_thread->joinable()) {
          self->event_thread->join();
      }
      delete self->event_thread;
      self->event_thread = nullptr;
  }
  return nullptr;
}

static void hotkey_api_plugin_dispose(GObject* object) {
  HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(object);
  if (self->monitoring) {
      self->monitoring = false;
      if (self->event_thread && self->event_thread->joinable()) {
          self->event_thread->join();
      }
      delete self->event_thread;
  }
  G_OBJECT_CLASS(hotkey_api_plugin_parent_class)->dispose(object);
}

static void hotkey_api_plugin_class_init(HotkeyApiPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = hotkey_api_plugin_dispose;
}

static void hotkey_api_plugin_init(HotkeyApiPlugin* self) {
    self->monitoring = false;
    self->event_thread = nullptr;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  // HotkeyApiPlugin* plugin = HOTKEY_API_PLUGIN(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  g_autoptr(FlMethodResponse) response = nullptr;

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("Linux")));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

void hotkey_api_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  HotkeyApiPlugin* plugin = HOTKEY_API_PLUGIN(
      g_object_new(hotkey_api_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->method_channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "hotkey_api/methods",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(plugin->method_channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin->event_channel = fl_event_channel_new(fl_plugin_registrar_get_messenger(registrar),
                                               "hotkey_api/events",
                                               FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(plugin->event_channel,
                                       event_stream_listen,
                                       event_stream_cancel,
                                       g_object_ref(plugin),
                                       g_object_unref);

  g_object_unref(plugin);
}
