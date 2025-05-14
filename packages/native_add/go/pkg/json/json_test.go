package json

import (
	"testing"
)

func TestToJSON(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected string
		hasError bool
	}{
		{
			name:     "简单map",
			input:    map[string]interface{}{"name": "张三", "age": 30},
			expected: `{"age":30,"name":"张三"}`,
			hasError: false,
		},
		{
			name:     "数字和布尔值",
			input:    map[string]interface{}{"value": 42, "active": true},
			expected: `{"active":true,"value":42}`,
			hasError: false,
		},
		{
			name:     "嵌套结构",
			input:    map[string]interface{}{"user": map[string]interface{}{"name": "李四", "id": 1001}},
			expected: `{"user":{"id":1001,"name":"李四"}}`,
			hasError: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result, err := ToJSON(tt.input)
			if (err != nil) != tt.hasError {
				t.Errorf("ToJSON() error = %v, expected hasError = %v", err, tt.hasError)
				return
			}
			if err == nil && result != tt.expected {
				t.Errorf("ToJSON() = %v, expected %v", result, tt.expected)
			}
		})
	}
}

func TestToMap(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected map[string]interface{}
		hasError bool
	}{
		{
			name:     "空JSON",
			input:    "{}",
			expected: map[string]interface{}{},
			hasError: false,
		},
		{
			name:     "简单JSON",
			input:    `{"name":"王五","age":25}`,
			expected: map[string]interface{}{"name": "王五", "age": float64(25)},
			hasError: false,
		},
		{
			name:     "无效JSON",
			input:    `{"name":"错误的JSON`,
			expected: nil,
			hasError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result, err := ToMap(tt.input)
			if (err != nil) != tt.hasError {
				t.Errorf("ToMap() error = %v, expected hasError = %v", err, tt.hasError)
				return
			}
			if err == nil {
				// 验证所有键值对是否匹配
				for k, v := range tt.expected {
					if rv, ok := result[k]; !ok || rv != v {
						t.Errorf("ToMap() = %v, expected %v", result, tt.expected)
						return
					}
				}
			}
		})
	}
}

func TestErrorResponse(t *testing.T) {
	result := ErrorResponse("测试错误")
	expected := `{"error":"测试错误"}`
	if result != expected {
		t.Errorf("ErrorResponse() = %v, expected %v", result, expected)
	}
}

func TestSuccessResponse(t *testing.T) {
	result := SuccessResponse(42)
	expected := `{"result":42}`
	if result != expected {
		t.Errorf("SuccessResponse() = %v, expected %v", result, expected)
	}
}
