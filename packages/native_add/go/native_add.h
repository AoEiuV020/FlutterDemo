#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// A very short-lived native function.
//
// For very short-lived functions, it is fine to call them on the main isolate.
// They will block the Dart execution while running the native function, so
// only do this for native functions which are guaranteed to be short-lived.
FFI_PLUGIN_EXPORT int sum(int a, int b);

// A longer lived native function, which occupies the thread calling it.
//
// Do not call these kind of native functions in the main isolate. They will
// block Dart execution. This will cause dropped frames in Flutter applications.
// Instead, call these native functions on a separate isolate.
FFI_PLUGIN_EXPORT int sum_long_running(int a, int b);

// String addition function
FFI_PLUGIN_EXPORT char* sum_string(const char* a, const char* b);

// 非常重要：您必须提供一个函数来释放 sum_string 返回的内存
FFI_PLUGIN_EXPORT void free_string(char* str);

// HTTP API function that calls a sum service via HTTP
// Returns result via int return value, and error message via char** out parameter
// If successful, error_message will be NULL
// If fails, result will be -1 and error_message will contain the error
FFI_PLUGIN_EXPORT int sum_via_http(int a, int b, char** error_message);

// Free the error message allocated by sum_via_http
FFI_PLUGIN_EXPORT void free_error_message(char* error_message);
