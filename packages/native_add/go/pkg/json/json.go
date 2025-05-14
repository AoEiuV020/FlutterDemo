// Package json 提供JSON处理相关的工具函数
package json

import (
	"encoding/json"
	"fmt"
)

// ToJSON 将任意数据结构转换为JSON字符串
func ToJSON(v interface{}) (string, error) {
	bytes, err := json.Marshal(v)
	if err != nil {
		return "", fmt.Errorf("序列化JSON失败: %w", err)
	}
	return string(bytes), nil
}

// ToMap 将JSON字符串解析为map[string]interface{}
func ToMap(jsonStr string) (map[string]interface{}, error) {
	if jsonStr == "" || jsonStr == "{}" {
		return make(map[string]interface{}), nil
	}

	var result map[string]interface{}
	if err := json.Unmarshal([]byte(jsonStr), &result); err != nil {
		return nil, fmt.Errorf("解析JSON失败: %w", err)
	}
	return result, nil
}

// ErrorResponse 生成包含错误信息的JSON字符串
func ErrorResponse(errMsg string) string {
	response := map[string]interface{}{
		"error": errMsg,
	}
	respJSON, _ := json.Marshal(response)
	return string(respJSON)
}

// SuccessResponse 生成包含结果的JSON字符串
func SuccessResponse(result interface{}) string {
	response := map[string]interface{}{
		"result": result,
	}
	respJSON, _ := json.Marshal(response)
	return string(respJSON)
}
