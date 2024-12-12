#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#include <gtk/gtkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include <iostream>
#include <fstream>
#include <ctime>
#include <string>

// 添加全局日志文件
static std::ofstream g_log_file;

// 添加日志函数
static void log_message(const char* message) {
    if (g_log_file.is_open()) {
        time_t now = time(0);
        char timestamp[32];
        strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", localtime(&now));
        g_log_file << timestamp << " - " << message << std::endl;
        g_log_file.flush();
    }
    std::cout << message << std::endl;
}

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  gboolean plug_mode;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void on_plug_embedded(GtkPlug* plug, gpointer user_data) {
  log_message("插件已成功嵌入");
}

static void on_plug_unrealized(GtkWidget* plug, gpointer user_data) {
  log_message("插件已被销毁");
}

static gboolean on_plug_delete(GtkWidget* plug, GdkEvent* event, gpointer user_data) {
  log_message("插件收到删除事件");
  GApplication* app = G_APPLICATION(user_data);
  g_application_release(app);
  return FALSE;
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  log_message("正在激活应用程序...");

  // Flutter 项目初始化
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  GtkWidget* window = NULL;

#ifdef GDK_WINDOWING_X11
  if (self->plug_mode) {
    log_message("创建插件窗口...");
    window = gtk_plug_new(0);
    if (!window) {
      log_message("创建插件失败！");
      return;
    }
    log_message("插件创建成功");

    Window xid = gtk_plug_get_id(GTK_PLUG(window));
    fprintf(stdout, "###plugId=%lu\n", xid);
    fflush(stdout);
    
    char msg[128];
    snprintf(msg, sizeof(msg), "插件ID: %lu", xid);
    log_message(msg);
    
    // 连接插件相关信号
    g_signal_connect(window, "delete-event", G_CALLBACK(on_plug_delete), application);
    g_signal_connect(window, "embedded", G_CALLBACK(on_plug_embedded), NULL);
    g_signal_connect(window, "unrealize", G_CALLBACK(on_plug_unrealized), NULL);

    // 保持应用程序运行
    g_application_hold(application);
    log_message("应用程序已保持运行（插件模式）");
  } else {
#endif
    // 独立窗口模式
    window = GTK_WIDGET(gtk_application_window_new(GTK_APPLICATION(application)));
    
    // 标题栏处理
    gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
    GdkScreen* screen = gtk_window_get_screen(GTK_WINDOW(window));
    if (GDK_IS_X11_SCREEN(screen)) {
      const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
      if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
        use_header_bar = FALSE;
      }
    }
#endif
    if (use_header_bar) {
      GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
      gtk_widget_show(GTK_WIDGET(header_bar));
      gtk_header_bar_set_title(header_bar, "meeting_flutter_example");
      gtk_header_bar_set_show_close_button(header_bar, TRUE);
      gtk_window_set_titlebar(GTK_WINDOW(window), GTK_WIDGET(header_bar));
    } else {
      gtk_window_set_title(GTK_WINDOW(window), "meeting_flutter_example");
    }

    gtk_window_set_default_size(GTK_WINDOW(window), 1280, 720);
#ifdef GDK_WINDOWING_X11
  }
#endif

  // 通用窗口设置
  
  // 创建 Flutter 视图
  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));

  // 注册插件（移到这里，确保所有模式都会执行）
  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));
  gtk_widget_show_all(window);
  gtk_widget_grab_focus(GTK_WIDGET(view));
  
  log_message("窗口创建和设置完成");
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  log_message("处理本地命令行参数...");

  // 保存 dart 入口参数
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    log_message("应用程序注册失败");
    *exit_status = 1;
    return TRUE;
  }

  // 返回 FALSE 让 command_line 处理参数
  return FALSE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  log_message("应用程序正在关闭");
  
  if (g_log_file.is_open()) {
    g_log_file.close();
  }
  
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static gint command_line(GApplication* application, GApplicationCommandLine* command_line) {
  MyApplication* self = MY_APPLICATION(application);
  
  gint argc;
  gchar** argv = g_application_command_line_get_arguments(command_line, &argc);
  
  log_message("开始解析命令行参数...");
  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--plugMode") == 0) {
      self->plug_mode = TRUE;
      log_message("设置为插件模式");
    }
  }
  
  g_strfreev(argv);
  log_message("命令行参数解析完成，激活应用程序");
  g_application_activate(application);
  return 0;
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->command_line = command_line;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {
  self->plug_mode = FALSE;
}

MyApplication* my_application_new() {
  // 打开日志文件
  if (!g_log_file.is_open()) {
    g_log_file.open("flutter_app.log", std::ios::app);
    if (!g_log_file.is_open()) {
      std::cerr << "打开日志文件失败" << std::endl;
    } else {
      log_message("日志文件打开成功");
    }
  }

  log_message("正在创建应用程序实例");

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                   "application-id", APPLICATION_ID,
                                   "flags", (GApplicationFlags)(G_APPLICATION_NON_UNIQUE | 
                                                             G_APPLICATION_HANDLES_COMMAND_LINE),
                                   nullptr));
}
