package main

import (
	"time"
)
func Sum(a int, b int) int {
	return a + b
}

func SumLongRunning(a int, b int) int {
	time.Sleep(1 * time.Second)
	return a + b
}
