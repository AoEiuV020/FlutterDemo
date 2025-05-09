//go:build cgo

package main

/*
#include <stdlib.h>
*/
import "C"
import "unsafe"

//export sum
func sum(a C.int, b C.int) C.int {
	return C.int(Sum(int(a), int(b)))
}

//export sum_long_running
func sum_long_running(a C.int, b C.int) C.int {
	return C.int(SumLongRunning(int(a), int(b)))
}

//export sum_string
func sum_string(a *C.char, b *C.char) *C.char {
	result := SumString(C.GoString(a), C.GoString(b))
	return C.CString(result)
}

//export free_string
func free_string(str *C.char) {
	// 使用 C.free 释放由 C.CString 分配的内存
	C.free(unsafe.Pointer(str))
}

func main() {
}
