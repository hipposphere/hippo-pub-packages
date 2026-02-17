#include "include/desktop_autopaste/desktop_autopaste_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>
#include <cstring>
#include <unistd.h>
#include <iostream>

#define DESKTOP_AUTOPASTE_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), desktop_autopaste_plugin_get_type(), \
                               DesktopAutopastePlugin))

struct _DesktopAutopastePlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(DesktopAutopastePlugin, desktop_autopaste_plugin, g_object_get_type())

// Helper to simulate Ctrl+V
static bool simulate_paste(Display* display) {
    if (!display) return false;
    
    // KeySyms for Ctrl and V
    KeyCode ctrl_code = XKeysymToKeycode(display, XK_Control_L);
    KeyCode v_code = XKeysymToKeycode(display, XK_v);
    
    // Press Ctrl
    XTestFakeKeyEvent(display, ctrl_code, True, 0);
    // Press V
    XTestFakeKeyEvent(display, v_code, True, 0);
    // Release V
    XTestFakeKeyEvent(display, v_code, False, 0);
    // Release Ctrl
    XTestFakeKeyEvent(display, ctrl_code, False, 0);
    
    XFlush(display);
    return true;
}

static FlMethodResponse* paste_into_cursor(FlValue* args) {
    // Arg is just text string usually? Or is it unused if we just trigger paste?
    // platform interface: pasteIntoCursor(String text).
    // Implementation:
    // 1. Set Clipboard (DesktopAutopaste usually implies putting text in clipboard then pasting)
    //    BUT the method name is pasteIntoCursor.
    //    Usually this means "Typer" or "Paste".
    //    If the argument is text, we should probably set the clipboard first.
    //    Let's check implementation of macOS/Windows.
    //    MacOS implementation usually uses Accessibility API to type or paste.
    //    If method implies "paste the text provided", we must set clipboard.
    //    "pasteIntoCursorViaClipboard" is explicit. "pasteIntoCursor" might mean "Type parameters" or "Cmd+V".
    //    Let's assume we set clipboard then paste.
    
    const char* text = nullptr;
    if (args && fl_value_get_type(args) == FL_VALUE_TYPE_STRING) {
        text = fl_value_get_string(args);
    } else if (args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
         FlValue* v = fl_value_lookup_string(args, "text");
         if(v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING) text = fl_value_get_string(v);
    }

    if (text) {
        GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
        gtk_clipboard_set_text(clipboard, text, -1);
        gtk_clipboard_store(clipboard); // Persist
        // Wait a bit?
        usleep(50000); // 50ms
    }

    Display* display = XOpenDisplay(NULL);
    if (!display) {
         return FL_METHOD_RESPONSE(fl_method_error_response_new("X11_ERROR", "Failed to open display", nullptr));
    }
    
    bool res = simulate_paste(display);
    XCloseDisplay(display);
    
    if (res)
        return FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(true)));
    else
        return FL_METHOD_RESPONSE(fl_method_error_response_new("PASTE_FAILED", "Failed to simulate paste", nullptr));
}

static FlMethodResponse* get_focused_text_field_context(FlValue* /*args*/) {
    FlValue* context = fl_value_new_map();
    fl_value_set_string(context, "available", fl_value_new_bool(false));
    fl_value_set_string(context, "reason", fl_value_new_string("notImplementedOnLinux"));
    return FL_METHOD_RESPONSE(fl_method_success_response_new(context));
}


static void desktop_autopaste_plugin_handle_method_call(
    DesktopAutopastePlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string("Linux")));
  } else if (strcmp(method, "pasteIntoCursor") == 0) {
      response = paste_into_cursor(args);
  } else if (strcmp(method, "pasteIntoCursorViaClipboard") == 0) {
       // logic is same if we just set clipboard then paste.
       response = paste_into_cursor(args);
  } else if (strcmp(method, "getFocusedTextFieldContext") == 0) {
      response = get_focused_text_field_context(args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void desktop_autopaste_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(desktop_autopaste_plugin_parent_class)->dispose(object);
}

static void desktop_autopaste_plugin_class_init(DesktopAutopastePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = desktop_autopaste_plugin_dispose;
}

static void desktop_autopaste_plugin_init(DesktopAutopastePlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DesktopAutopastePlugin* plugin = DESKTOP_AUTOPASTE_PLUGIN(user_data);
  desktop_autopaste_plugin_handle_method_call(plugin, method_call);
}

void desktop_autopaste_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DesktopAutopastePlugin* plugin = DESKTOP_AUTOPASTE_PLUGIN(
      g_object_new(desktop_autopaste_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "desktop_autopaste",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
