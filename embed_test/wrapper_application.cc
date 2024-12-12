#include "wrapper_application.h"
#include <gtk/gtkx.h>
#include <gdk/gdkx.h>
#include <iostream>
#include <string>

struct _WrapperApplication {
  GtkApplication parent_instance;
  GtkWidget* socket;  // 用于嵌入窗口的socket
  GtkWidget* container;  // 容器用于放置socket
};

G_DEFINE_TYPE(WrapperApplication, wrapper_application, GTK_TYPE_APPLICATION)

static void wrapper_application_init(WrapperApplication* self) {
  self->socket = NULL;
  self->container = NULL;
}

static void on_socket_plug_added(GtkSocket* socket, gpointer user_data) {
  std::cout << "插件已添加到socket中" << std::endl;
}

static gboolean on_socket_plug_removed(GtkSocket* socket, gpointer user_data) {
  std::cout << "插件已从socket中移除" << std::endl;
  return TRUE;  // 保持socket存活
}

static void process_line(GIOChannel* channel, const gchar* line, WrapperApplication* app) {
    // 先打印所有输出
    std::cout << "Inner: " << line;  // line已经包含换行符，所以不需要额外添加
    
    // 检查是否是plug ID行并处理
    if (strncmp(line, "###plugId=", 10) == 0) {
        // 解析inner应用输出的plug ID
        gulong xid = strtoul(line + 10, NULL, 10);
        if (xid == 0) {
            std::cout << "无效的plug ID" << std::endl;
            return;
        }
        
        std::cout << "收到plug ID: " << xid << std::endl;
        
        // 创建新的socket
        if (app->socket) {
            gtk_widget_destroy(app->socket);
        }
        
        app->socket = gtk_socket_new();
        
        // 连接socket信号
        g_signal_connect(app->socket, "plug-added", G_CALLBACK(on_socket_plug_added), NULL);
        g_signal_connect(app->socket, "plug-removed", G_CALLBACK(on_socket_plug_removed), NULL);
        
        // 将socket添加到容器中，并设置为填充
        if (app->container) {
            gtk_container_add(GTK_CONTAINER(app->container), app->socket);
            gtk_widget_set_hexpand(app->socket, TRUE);
            gtk_widget_set_vexpand(app->socket, TRUE);
        }
        
        // 绑定到指定的plug ID
        gtk_socket_add_id(GTK_SOCKET(app->socket), xid);
        gtk_widget_show_all(app->socket);
    }
}

static gboolean watch_child_output(GIOChannel* channel, GIOCondition condition, gpointer data) {
    WrapperApplication* app = WRAPPER_APPLICATION(data);
    gchar* line = NULL;
    gsize len;
    GError* error = NULL;
    
    if (condition & G_IO_HUP) {
        std::cout << "子进程输出流关闭" << std::endl;
        g_io_channel_unref(channel);
        return FALSE;
    }
    
    if (condition & G_IO_IN) {
        switch (g_io_channel_read_line(channel, &line, &len, NULL, &error)) {
            case G_IO_STATUS_NORMAL:
                if (line) {
                    process_line(channel, line, app);
                    g_free(line);
                }
                return TRUE;
            case G_IO_STATUS_ERROR:
                std::cout << "读取子进程输出时发生错误: " << error->message << std::endl;
                g_error_free(error);
                break;
            case G_IO_STATUS_EOF:
                std::cout << "子进程输出已结束" << std::endl;
                break;
            case G_IO_STATUS_AGAIN:
                return TRUE;
        }
    }
    
    g_io_channel_unref(channel);
    return FALSE;
}

static void launch_inner_app(GtkButton* button, WrapperApplication* app) {
    std::cout << "启动inner应用..." << std::endl;
    
    gint child_stdout;
    GPid child_pid;
    GError* error = NULL;
    
    // 构造完整的application-id
    const gchar* wrapper_id = g_application_get_application_id(G_APPLICATION(app));
    std::string inner_id = std::string(wrapper_id) + ".inner";
    
    gchar* argv[] = {
        (char*)"./inner",
        (char*)"--plugMode",
        (char*)"--applicationId",
        (char*)inner_id.c_str(),
        NULL
    };
    
    // 启动inner应用，并捕获其标准输出和标准错误
    if (!g_spawn_async_with_pipes(NULL,
                                 argv,
                                 NULL,
                                 (GSpawnFlags)(G_SPAWN_SEARCH_PATH | G_SPAWN_DO_NOT_REAP_CHILD),
                                 NULL,
                                 NULL,
                                 &child_pid,
                                 NULL,
                                 &child_stdout,
                                 NULL,
                                 &error)) {
        std::cout << "启动inner应用失败: " << error->message << std::endl;
        g_error_free(error);
        return;
    }
    
    // 监视子进程的标准输出
    GIOChannel* channel = g_io_channel_unix_new(child_stdout);
    g_io_channel_set_encoding(channel, NULL, NULL);
    g_io_channel_set_flags(channel, G_IO_FLAG_NONBLOCK, NULL);
    g_io_channel_set_buffer_size(channel, 4096);
    
    // 添加监视
    g_io_add_watch(channel, (GIOCondition)(G_IO_IN | G_IO_HUP), watch_child_output, app);
    
    // 设置子进程结束时的回调
    g_child_watch_add(child_pid, (GChildWatchFunc)g_spawn_close_pid, NULL);
}

static void activate(GApplication* app) {
  WrapperApplication* self = WRAPPER_APPLICATION(app);
  GtkWindow* window;
  
  window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(app)));
  gtk_window_set_title(window, "Wrapper Window");
  gtk_window_set_default_size(window, 800, 600);
  
  // 创建垂直布局容器
  GtkWidget* box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
  gtk_container_add(GTK_CONTAINER(window), box);
  
  // 添加启动按钮，设置不扩展
  GtkWidget* button = gtk_button_new_with_label("启动Inner应用");
  gtk_box_pack_start(GTK_BOX(box), button, FALSE, FALSE, 5);
  
  // 创建容器用于放置socket，设置为填充剩余空间
  self->container = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_widget_set_hexpand(self->container, TRUE);
  gtk_widget_set_vexpand(self->container, TRUE);
  gtk_box_pack_start(GTK_BOX(box), self->container, TRUE, TRUE, 0);
  
  // 连接按钮点击信号
  g_signal_connect(button, "clicked", G_CALLBACK(launch_inner_app), self);
  
  gtk_widget_show_all(GTK_WIDGET(window));
}

static void wrapper_application_class_init(WrapperApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = activate;
}

WrapperApplication* wrapper_application_new(void) {
  return WRAPPER_APPLICATION(g_object_new(wrapper_application_get_type(),
                                        "application-id", "com.example.wrapper",
                                        "flags", G_APPLICATION_FLAGS_NONE,
                                        nullptr));
} 