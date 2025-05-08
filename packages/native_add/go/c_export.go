//go:build cgo

package main

import "C"

//export sum
func sum(a C.int, b C.int) C.int {
	return C.int(Sum(int(a), int(b)))
}

//export sum_long_running
func sum_long_running(a C.int, b C.int) C.int {
	return C.int(SumLongRunning(int(a), int(b)))
}

func main() {
}
