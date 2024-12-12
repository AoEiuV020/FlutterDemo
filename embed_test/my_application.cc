#include "my_application.h"
#include <gtk/gtkx.h>
#include <gdk/gdkx.h>
#include <iostream>
#include <fstream>
#include <ctime>
#include <string>

// 全局日志文件
static std::ofstream g_log_file;

struct _MyApplication {
    GtkApplication parent_instance;
    GtkWidget* plug;  // 存储plug窗口
    gboolean plug_mode;  // 是否为插件模式
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// 解析命令行参数，返回application-id
static const char* parse_application_id(int argc, char** argv) {
    static const char* default_id = "com.example.inner";
    
    for (int i = 1; i < argc - 1; i++) {
        if (strcmp(argv[i], "--applicationId") == 0) {
            return argv[i + 1];
        }
    }
    return default_id;
}

// 日志函数
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

// 按钮点击回调
static void on_button_clicked(GtkButton* button, gpointer user_data) {
    log_message("按钮被点击");
}

// 输入框变化回调
static void on_entry_changed(GtkEntry* entry, gpointer user_data) {
    const gchar* text = gtk_entry_get_text(entry);
    std::string msg = "输入框内容已更改: " + std::string(text);
    log_message(msg.c_str());
}

// 封装UI创建逻辑
static GtkWidget* create_inner_ui(void) {
    log_message("开始创建内部UI");
    
    // 创建一个垂直布局容器
    GtkWidget* box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5);
    log_message("已创建垂直布局容器");
    
    // 创建标签
    GtkWidget* label = gtk_label_new("Inner Application");
    gtk_box_pack_start(GTK_BOX(box), label, FALSE, FALSE, 5);
    log_message("已添加标签到布局中");
    
    // 添加一些示例件
    GtkWidget* button = gtk_button_new_with_label("测试按钮");
    g_signal_connect(button, "clicked", G_CALLBACK(on_button_clicked), NULL);
    gtk_box_pack_start(GTK_BOX(box), button, FALSE, FALSE, 5);
    log_message("已添加按钮到布局中");
    
    GtkWidget* entry = gtk_entry_new();
    gtk_entry_set_placeholder_text(GTK_ENTRY(entry), "输入些文字...");
    g_signal_connect(entry, "changed", G_CALLBACK(on_entry_changed), NULL);
    gtk_box_pack_start(GTK_BOX(box), entry, FALSE, FALSE, 5);
    log_message("已添加输入框到布局中");
    
    log_message("内部UI创建完成");
    return box;
}

static gint command_line(GApplication* application, GApplicationCommandLine* command_line) {
    MyApplication* self = MY_APPLICATION(application);
    
    // 获取原始命令行参数
    gint argc;
    gchar** argv = g_application_command_line_get_arguments(command_line, &argc);
    
    // 手动解析参数
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--plugMode") == 0) {
            self->plug_mode = TRUE;
            log_message("以插件模式启动");
        }
        // 忽略其他参数，包括applicationId（已在创建时处理）
    }
    
    g_strfreev(argv);
    
    // 如果没有指定插件模式，���为独立窗口模式
    if (!self->plug_mode) {
        log_message("以独立窗口模式启动");
    }
    
    // 激活应用程序
    g_application_activate(application);
    return 0;
}

static void on_plug_embedded(GtkPlug* plug, gpointer user_data) {
    log_message("插件已成功嵌入到Socket中");
}

static void on_plug_unrealized(GtkWidget* plug, gpointer user_data) {
    log_message("插件已被销毁");
}

static gboolean on_plug_delete(GtkWidget* plug, GdkEvent* event, gpointer user_data) {
    log_message("插件收到删除事件，准备退出");
    GApplication* app = G_APPLICATION(user_data);
    // 释放应用程序的hold，允许其退出
    g_application_release(app);
    return FALSE;  // 允许事件继续传播，使plug被销毁
}

// 实现 GApplication::activate
static void my_application_activate(GApplication* application) {
    log_message("进入应用程序激活函数");
    
    MyApplication* self = MY_APPLICATION(application);
    log_message("开始创建UI元素");
    
    GtkWidget* ui = create_inner_ui();
    
    if (self->plug_mode) {
        // 插件模式
        self->plug = gtk_plug_new(0);  // 0表示创建一个新的顶层窗口
        if (!self->plug) {
            log_message("创建插件失败！");
            return;
        }
        log_message("插件创建成功");

        // 获取并输出plug ID
        Window xid = gtk_plug_get_id(GTK_PLUG(self->plug));
        // 使用特定格式输出ID
        fprintf(stdout, "###plugId=%lu\n", xid);
        fflush(stdout);
        std::string msg = "已输出Plug ID: " + std::to_string(xid);
        log_message(msg.c_str());
        
        // 连接plug事件
        g_signal_connect(self->plug, "delete-event", G_CALLBACK(on_plug_delete), application);
        g_signal_connect(self->plug, "embedded", G_CALLBACK(on_plug_embedded), NULL);
        g_signal_connect(self->plug, "unrealize", G_CALLBACK(on_plug_unrealized), NULL);
        log_message("已连接插件信号");
        
        gtk_container_add(GTK_CONTAINER(self->plug), ui);
        log_message("已将UI添加到插件中");
        
        gtk_widget_show_all(self->plug);
        log_message("已显示所有插件控件");
        
        // 保持应用程序运行
        g_application_hold(application);
        log_message("应用程序已保持运行状态（插件模式）");
    } else {
        // 独立窗口模式
        log_message("创建独立窗口");
        GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
        gtk_window_set_title(window, "Inner Window");
        gtk_window_set_default_size(window, 400, 300);
        gtk_container_add(GTK_CONTAINER(window), ui);
        gtk_widget_show_all(GTK_WIDGET(window));
        log_message("独立窗口已创建并显示");
    }
}

static void my_application_startup(GApplication* application) {
    log_message("应用程序启动开始");
    
    G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
    log_message("应用程序启动完成");
}

static void my_application_shutdown(GApplication* application) {
    log_message("应用程序开始关闭");
    
    if (g_log_file.is_open()) {
        g_log_file.close();
    }
    
    G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
    log_message("应用程序已完全关闭");
}

static void my_application_class_init(MyApplicationClass* klass) {
    log_message("正在初始化应用程序类");
    G_APPLICATION_CLASS(klass)->startup = my_application_startup;
    G_APPLICATION_CLASS(klass)->activate = my_application_activate;
    G_APPLICATION_CLASS(klass)->command_line = command_line;
    G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
    log_message("应用程序类初始化完成");
}

static void my_application_init(MyApplication* self) {
    self->plug = NULL;
    self->plug_mode = FALSE;
    log_message("应用程序实例已初始化");
}

MyApplication* my_application_new(int argc, char** argv) {
    // 打开日志文件
    if (!g_log_file.is_open()) {
        g_log_file.open("inner_app.log", std::ios::app);
        if (!g_log_file.is_open()) {
            std::cerr << "打开日志文件失败" << std::endl;
        } else {
            log_message("成功打开日志文件");
        }
    }
    log_message("正在创建新的应用程序实例");
    
    // 从命令行获取application-id
    const char* app_id = parse_application_id(argc, argv);
    std::string msg = "使用application-id: " + std::string(app_id);
    log_message(msg.c_str());
    
    // 只使用命令行处理标志，不注册选项
    GApplicationFlags flags = (GApplicationFlags)(G_APPLICATION_FLAGS_NONE | 
                                                G_APPLICATION_HANDLES_COMMAND_LINE);
    
    MyApplication* app = MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", app_id,
                                     "flags", flags,
                                     NULL));
    
    log_message("应用程序实例创建完成");
    
    return app;
} 