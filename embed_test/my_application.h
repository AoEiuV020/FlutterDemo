#ifndef MY_APPLICATION_H
#define MY_APPLICATION_H

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION, GtkApplication)

/**
 * my_application_new:
 * @argc: 命令行参数数量
 * @argv: 命令行参数数组
 * 
 * 创建一个新的GTK应用程序实例
 * 
 * Returns: 返回一个新的MyApplication实例
 */
MyApplication* my_application_new(int argc, char** argv);

#endif // MY_APPLICATION_H 