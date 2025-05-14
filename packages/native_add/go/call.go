package main

import (
	"fmt"
	"native_add/pkg/json"
)

// Call 根据方法名和JSON参数字符串调用对应函数
// method: 要调用的方法名
// paramJSON: 包含参数的JSON字符串
// 返回: 包含执行结果的JSON字符串
func Call(method string, paramJSON string) string {
	// 解析JSON参数为map
	params, err := json.ToMap(paramJSON)
	if err != nil {
		return json.ErrorResponse(fmt.Sprintf("解析参数失败: %v", err))
	}

	// 调用Execute函数执行具体逻辑
	resultMap := Execute(method, params)

	// 将结果转换为JSON字符串
	resultJSON, err := json.ToJSON(resultMap)
	if err != nil {
		return json.ErrorResponse(fmt.Sprintf("序列化结果失败: %v", err))
	}

	return resultJSON
}

// Execute 执行具体函数调用并返回结果map
// method: 要调用的方法名
// params: 参数map
// 返回: 包含执行结果的map
func Execute(method string, params map[string]interface{}) map[string]interface{} {
	result := make(map[string]interface{})

	// 封装所有可能的异常
	defer func() {
		if r := recover(); r != nil {
			result["error"] = fmt.Sprintf("发生未捕获的异常: %v", r)
		}
	}()
	// 根据方法名调用不同函数
	switch method {
	case "Sum":
		// 提取参数
		a, aOk := params["a"]
		b, bOk := params["b"]
		if !aOk || !bOk {
			result["error"] = "缺少必要参数 a 或 b"
			return result
		}

		// 先转换为整数
		aFloat, aOk := a.(float64)
		if !aOk {
			result["error"] = fmt.Sprintf("参数 a 类型错误: 期望整数, 实际 %T", a)
			return result
		}
		aInt := int(aFloat)

		bFloat, bOk := b.(float64)
		if !bOk {
			result["error"] = fmt.Sprintf("参数 b 类型错误: 期望整数, 实际 %T", b)
			return result
		}
		bInt := int(bFloat)

		// 直接使用整数调用Sum函数
		result["result"] = Sum(aInt, bInt)

	case "SumString":
		// 提取参数
		a, aOk := params["a"]
		b, bOk := params["b"]
		if !aOk || !bOk {
			result["error"] = "缺少必要参数 a 或 b"
			return result
		}

		// 转换为字符串
		aStr, aOk := a.(string)
		if !aOk {
			result["error"] = fmt.Sprintf("参数 a 类型错误: 期望字符串, 实际 %T", a)
			return result
		}

		bStr, bOk := b.(string)
		if !bOk {
			result["error"] = fmt.Sprintf("参数 b 类型错误: 期望字符串, 实际 %T", b)
			return result
		}

		// 调用SumString函数
		result["result"] = SumString(aStr, bStr)

	case "Increase":
		// Increase 不需要参数
		result["result"] = Increase()
	case "SumLongRunning":
		// 提取参数
		a, aOk := params["a"]
		b, bOk := params["b"]
		if !aOk || !bOk {
			result["error"] = "缺少必要参数 a 或 b"
			return result
		}

		// 先转换为整数
		aFloat, aOk := a.(float64)
		if !aOk {
			result["error"] = fmt.Sprintf("参数 a 类型错误: 期望整数, 实际 %T", a)
			return result
		}
		aInt := int(aFloat)

		bFloat, bOk := b.(float64)
		if !bOk {
			result["error"] = fmt.Sprintf("参数 b 类型错误: 期望整数, 实际 %T", b)
			return result
		}
		bInt := int(bFloat)

		// 直接使用整数调用SumLongRunning函数
		result["result"] = SumLongRunning(aInt, bInt)
	case "SumViaHTTP":
		// 提取参数
		a, aOk := params["a"]
		b, bOk := params["b"]
		if !aOk || !bOk {
			result["error"] = "缺少必要参数 a 或 b"
			return result
		}

		// 先转换为整数
		aFloat, aOk := a.(float64)
		if !aOk {
			result["error"] = fmt.Sprintf("参数 a 类型错误: 期望整数, 实际 %T", a)
			return result
		}
		aInt := int(aFloat)

		bFloat, bOk := b.(float64)
		if !bOk {
			result["error"] = fmt.Sprintf("参数 b 类型错误: 期望整数, 实际 %T", b)
			return result
		}
		bInt := int(bFloat)

		// 直接使用整数调用SumViaHTTP函数
		sumResult, err := SumViaHTTP(aInt, bInt)
		if err != nil {
			result["error"] = fmt.Sprintf("HTTP调用失败: %v", err)
			return result
		}
		result["result"] = sumResult

	default:
		result["error"] = fmt.Sprintf("未知方法: %s", method)
	}

	return result
}
