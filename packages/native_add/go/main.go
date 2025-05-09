package main

import (
	"strconv"
	"time"
)
func Sum(a int, b int) int {
	return a + b
}

func SumString(a string, b string) string {
	aInt, err1 := strconv.Atoi(a)
	bInt, err2 := strconv.Atoi(b)
	if err1 != nil || err2 != nil {
		return "0"
	}
	return strconv.Itoa(aInt + bInt)
}

func SumLongRunning(a int, b int) int {
	time.Sleep(1 * time.Second)
	return a + b
}
