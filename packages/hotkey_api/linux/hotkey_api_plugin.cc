#include "include/hotkey_api/hotkey_api_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/extensions/XInput2.h>
#include <atomic>
#include <chrono>
#include <iostream>
#include <set>
#include <thread>

#define HOTKEY_API_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), hotkey_api_plugin_get_type(), \
                               HotkeyApiPlugin))

struct _HotkeyApiPlugin {
  GObject parent_instance;
  FlMethodChannel* method_channel;
  FlEventChannel* event_channel;
  FlView* view;
  std::thread* event_thread;
  std::atomic<bool>* monitoring;
  std::set<int>* local_pressed_keys;
  gulong key_press_handler_id;
  gulong key_release_handler_id;
};

G_DEFINE_TYPE(HotkeyApiPlugin, hotkey_api_plugin, g_object_get_type())

// Struct to pass data to main thread
struct KeyEventData {
    HotkeyApiPlugin* plugin;
    int keycode;
    const char* type;
};

static void emit_key_event(HotkeyApiPlugin* plugin, int keycode, const char* type) {
    if (!plugin->event_channel) return;

    g_autoptr(FlValue) map = fl_value_new_map();
    fl_value_set_string_take(map, "key", fl_value_new_int(keycode));
    fl_value_set_string_take(map, "type", fl_value_new_string(type));

    fl_event_channel_send(plugin->event_channel, map, nullptr, nullptr);
}

// Callback to send event on main thread
static gboolean send_event_on_main(gpointer user_data) {
    KeyEventData* data = static_cast<KeyEventData*>(user_data);
    emit_key_event(data->plugin, data->keycode, data->type);
    g_object_unref(data->plugin);
    delete data;
    return G_SOURCE_REMOVE;
}

static void queue_key_event(HotkeyApiPlugin* plugin, int keycode, const char* type) {
    KeyEventData* data = new KeyEventData();
    data->plugin = HOTKEY_API_PLUGIN(g_object_ref(plugin));
    data->keycode = keycode;
    data->type = type;

    g_idle_add(send_event_on_main, data);
}

static gboolean handle_local_key_event(GtkWidget* widget, GdkEventKey* event,
                                       gpointer user_data) {
    HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(user_data);
    if (!self->monitoring->load()) return GDK_EVENT_PROPAGATE;

    guint16 keycode = 0;
    gdk_event_get_keycode(reinterpret_cast<GdkEvent*>(event), &keycode);

    const char* type = nullptr;
    if (event->type == GDK_KEY_PRESS) {
        if (self->local_pressed_keys->count(keycode) > 0) {
            type = "repeat";
        } else {
            self->local_pressed_keys->insert(keycode);
            type = "down";
        }
    } else if (event->type == GDK_KEY_RELEASE) {
        self->local_pressed_keys->erase(keycode);
        type = "up";
    }

    if (type != nullptr) {
        emit_key_event(self, keycode, type);
    }

    return GDK_EVENT_PROPAGATE;
}

static void connect_local_key_events(HotkeyApiPlugin* self) {
    if (!self->view) return;
    if (self->key_press_handler_id == 0) {
        self->key_press_handler_id = g_signal_connect(
            self->view, "key-press-event", G_CALLBACK(handle_local_key_event), self);
    }
    if (self->key_release_handler_id == 0) {
        self->key_release_handler_id = g_signal_connect(
            self->view, "key-release-event", G_CALLBACK(handle_local_key_event), self);
    }
}

static void disconnect_local_key_events(HotkeyApiPlugin* self) {
    if (!self->view) return;
    if (self->key_press_handler_id != 0) {
        g_signal_handler_disconnect(self->view, self->key_press_handler_id);
        self->key_press_handler_id = 0;
    }
    if (self->key_release_handler_id != 0) {
        g_signal_handler_disconnect(self->view, self->key_release_handler_id);
        self->key_release_handler_id = 0;
    }
    if (self->local_pressed_keys) {
        self->local_pressed_keys->clear();
    }
}

static void monitor_thread_func(HotkeyApiPlugin* self) {
    Display* dpy = XOpenDisplay(NULL);
    if (!dpy) {
        std::cerr << "Failed to open X display for hotkey monitoring" << std::endl;
        return;
    }

    int xi_opcode, event, error;
    if (!XQueryExtension(dpy, "XInputExtension", &xi_opcode, &event, &error)) {
        std::cerr << "XInput2 extension is not available for hotkey monitoring" << std::endl;
        XCloseDisplay(dpy);
        return;
    }

    int major = 2;
    int minor = 0;
    if (XIQueryVersion(dpy, &major, &minor) != Success) {
        std::cerr << "XInput2 is not available for hotkey monitoring" << std::endl;
        XCloseDisplay(dpy);
        return;
    }

    Window root = DefaultRootWindow(dpy);
    std::set<int> pressed_keys;
    
    XIEventMask mask;
    unsigned char mask_bits[XIMaskLen(XI_LASTEVENT)] = {0};
    
    mask.deviceid = XIAllMasterDevices;
    mask.mask_len = sizeof(mask_bits);
    mask.mask = mask_bits;
    
    XISetMask(mask.mask, XI_RawKeyPress);
    XISetMask(mask.mask, XI_RawKeyRelease);
    
    if (XISelectEvents(dpy, root, &mask, 1) != Success) {
        std::cerr << "Failed to select XInput2 raw key events for hotkey monitoring" << std::endl;
        XCloseDisplay(dpy);
        return;
    }
    XSync(dpy, False);

    while (self->monitoring->load()) {
        if (XPending(dpy) == 0) {
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            continue;
        }

        XEvent ev;
        XNextEvent(dpy, &ev);

        if (ev.xcookie.type == GenericEvent &&
            ev.xcookie.extension == xi_opcode &&
            XGetEventData(dpy, &ev.xcookie)) {
            if (ev.xcookie.evtype == XI_RawKeyPress ||
                ev.xcookie.evtype == XI_RawKeyRelease) {
                XIRawEvent* xiev = static_cast<XIRawEvent*>(ev.xcookie.data);
                const int keycode = xiev->detail;
                const char* type = nullptr;

                if (ev.xcookie.evtype == XI_RawKeyPress) {
                    if (pressed_keys.count(keycode) > 0) {
                        type = "repeat";
                    } else {
                        pressed_keys.insert(keycode);
                        type = "down";
                    }
                } else {
                    pressed_keys.erase(keycode);
                    type = "up";
                }

                queue_key_event(self, keycode, type);
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
  if (self->monitoring->load()) return nullptr;

  self->monitoring->store(true);
  self->local_pressed_keys->clear();

  GdkDisplay* display = gdk_display_get_default();
  if (display != nullptr && GDK_IS_X11_DISPLAY(display)) {
      self->event_thread = new std::thread(monitor_thread_func, self);
  } else {
      connect_local_key_events(self);
      std::cerr << "Wayland does not expose global raw keyboard events; "
                << "hotkey_api is listening to focused Flutter window events only"
                << std::endl;
  }

  return nullptr;
}

static void stop_monitoring(HotkeyApiPlugin* self) {
  if (!self->monitoring) return;
  if (self->monitoring->load()) {
      self->monitoring->store(false);
      disconnect_local_key_events(self);
      if (self->event_thread && self->event_thread->joinable()) {
          self->event_thread->join();
      }
      delete self->event_thread;
      self->event_thread = nullptr;
  }
}

static FlMethodErrorResponse* event_stream_cancel(FlEventChannel* channel,
                                                  FlValue* args,
                                                  gpointer user_data) {
  HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(user_data);
  stop_monitoring(self);
  return nullptr;
}

static void hotkey_api_plugin_dispose(GObject* object) {
  HotkeyApiPlugin* self = HOTKEY_API_PLUGIN(object);
  stop_monitoring(self);
  if (self->view) {
      g_object_remove_weak_pointer(G_OBJECT(self->view),
                                   reinterpret_cast<gpointer*>(&self->view));
      self->view = nullptr;
  }
  g_clear_object(&self->method_channel);
  g_clear_object(&self->event_channel);
  delete self->monitoring;
  self->monitoring = nullptr;
  delete self->local_pressed_keys;
  self->local_pressed_keys = nullptr;
  G_OBJECT_CLASS(hotkey_api_plugin_parent_class)->dispose(object);
}

static void hotkey_api_plugin_class_init(HotkeyApiPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = hotkey_api_plugin_dispose;
}

static void hotkey_api_plugin_init(HotkeyApiPlugin* self) {
    self->monitoring = new std::atomic<bool>(false);
    self->event_thread = nullptr;
    self->local_pressed_keys = new std::set<int>();
    self->key_press_handler_id = 0;
    self->key_release_handler_id = 0;
    self->view = nullptr;
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
  plugin->view = fl_plugin_registrar_get_view(registrar);
  if (plugin->view) {
      g_object_add_weak_pointer(G_OBJECT(plugin->view),
                                reinterpret_cast<gpointer*>(&plugin->view));
  }

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
