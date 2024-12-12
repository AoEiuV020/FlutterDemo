#ifndef WRAPPER_APPLICATION_H
#define WRAPPER_APPLICATION_H

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(WrapperApplication, wrapper_application, WRAPPER, APPLICATION, GtkApplication)

/**
 * wrapper_application_new:
 * 
 * 创建一个新的Wrapper GTK应用程序实例
 * 
 * Returns: 返回一个新的WrapperApplication实例
 */
WrapperApplication* wrapper_application_new(void);

#endif // WRAPPER_APPLICATION_H 