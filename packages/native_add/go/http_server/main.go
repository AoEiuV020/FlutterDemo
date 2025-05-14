package main

import (
	"fmt"
	"net/http"
	"strconv"
	"time"
)

const port = 8080

func main() {
	// 注册处理函数
	http.HandleFunc("/sum", handleSum)

	// 启动HTTP服务器
	address := fmt.Sprintf(":%d", port)
	fmt.Printf("HTTP服务正在启动，监听端口 %d...\n", port)
	err := http.ListenAndServe(address, nil)
	if err != nil {
		fmt.Printf("HTTP服务启动失败: %s\n", err)
	}
}

// handleSum 处理加法请求
func handleSum(w http.ResponseWriter, r *http.Request) {
	// 获取请求参数
	a := r.URL.Query().Get("a")
	b := r.URL.Query().Get("b")

	// 转换参数为整数
	aInt, err1 := strconv.Atoi(a)
	bInt, err2 := strconv.Atoi(b)

	// 处理参数错误
	if err1 != nil || err2 != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "参数错误")
		return
	}

	// 延迟0.2秒
	time.Sleep(200 * time.Millisecond)

	// 计算并返回结果
	result := aInt + bInt
	fmt.Fprintf(w, "%d", result)
}
