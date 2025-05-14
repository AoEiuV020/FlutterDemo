package main

import (
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"
)

// 全局计数器变量
var counter int = 0

// Increase 每次调用将全局计数器加一并返回
func Increase() int {
	counter++
	return counter
}

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

// SumViaHTTP 通过HTTP服务调用sum功能
func SumViaHTTP(a int, b int) (int, error) {
	// 构建请求URL
	url := fmt.Sprintf("http://localhost:%d/sum?a=%d&b=%d", 8080, a, b)

	// 发送HTTP请求
	resp, err := http.Get(url)
	if err != nil {
		return 0, fmt.Errorf("HTTP请求失败: %w", err)
	}
	defer resp.Body.Close()
	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, fmt.Errorf("读取响应失败: %w", err)
	}

	// 检查响应状态码
	if resp.StatusCode != http.StatusOK {
		return 0, fmt.Errorf("服务器返回错误: %s", string(body))
	}

	// 解析结果
	result, err := strconv.Atoi(string(body))
	if err != nil {
		return 0, fmt.Errorf("解析结果失败: %w", err)
	}

	return result, nil
}
