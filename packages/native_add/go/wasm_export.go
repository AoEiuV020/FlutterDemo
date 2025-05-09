//go:build wasm
package main

import (
    "syscall/js"
)

// PromiseFunc 定义需要被Promise化的函数类型
type PromiseFunc func(args []js.Value) interface{}

// ToPromise 将Go函数封装为返回Promise的JS函数
func ToPromise(fn PromiseFunc) js.Func {
    return js.FuncOf(func(this js.Value, args []js.Value) interface{} {
        // 创建Promise对象
        promise := js.Global().Get("Promise")
        
        // 返回一个新的Promise
        return promise.New(js.FuncOf(func(this js.Value, promiseArgs []js.Value) interface{} {
            resolve := promiseArgs[0]
            reject := promiseArgs[1]
            
            go func() {
                defer func() {
                    if r := recover(); r != nil {
                        // 捕获panic并reject
                        reject.Invoke(js.ValueOf(r.(error).Error()))
                    }
                }()
                
                // 执行实际函数
                result := fn(args)
                resolve.Invoke(js.ValueOf(result))
            }()
            
            return nil
        }))
    })
}

func registerCallbacks() {
    // 普通同步函数
    js.Global().Set("sum", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
        a := args[0].Int()
        b := args[1].Int()
        return Sum(a, b)
    }))
    
    // 字符串加法函数
    js.Global().Set("sum_string", js.FuncOf(func(this js.Value, args []js.Value) interface{} {
        a := args[0].String()
        b := args[1].String()
        return SumString(a, b)
    }))
    
    // 使用Promise封装的函数
    js.Global().Set("sum_long_running", ToPromise(func(args []js.Value) interface{} {
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