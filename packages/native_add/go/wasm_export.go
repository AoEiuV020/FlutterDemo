//go:build wasm

package main

import "syscall/js"

func registerCallbacks() {
    js.Global().Set("sum", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
        a := args[0].Int()
        b := args[1].Int()
        return Sum(a, b)
    }))
    js.Global().Set("sum_long_running", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
        a := args[0].Int()
        b := args[1].Int()
        return SumLongRunning(a, b)
    }))
}

func main() {
    registerCallbacks()
    // 保持程序运行
    select {}
}