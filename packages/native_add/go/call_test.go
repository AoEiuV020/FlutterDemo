package main

import (
	"strings"
	"testing"
)

func TestCall(t *testing.T) {
	tests := []struct {
		name        string
		method      string
		paramJSON   string
		wantContain string
		wantError   bool
	}{
		{
			name:        "Sum with valid params",
			method:      "Sum",
			paramJSON:   `{"a":5,"b":3}`,
			wantContain: `"result":8`,
			wantError:   false,
		},
		{
			name:        "Sum with invalid param type",
			method:      "Sum",
			paramJSON:   `{"a":"not-a-number","b":3}`,
			wantContain: `"error"`,
			wantError:   true,
		},
		{
			name:        "SumString with valid params",
			method:      "SumString",
			paramJSON:   `{"a":"5","b":"3"}`,
			wantContain: `"result":"8"`,
			wantError:   false,
		},
		{
			name:        "Increase",
			method:      "Increase",
			paramJSON:   `{}`,
			wantContain: `"result":`,
			wantError:   false,
		},
		{
			name:        "Unknown method",
			method:      "UnknownMethod",
			paramJSON:   `{}`,
			wantContain: `"error"`,
			wantError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := Call(tt.method, tt.paramJSON)

			if !strings.Contains(result, tt.wantContain) {
				t.Errorf("Call() = %v, should contain %v", result, tt.wantContain)
			}

			hasError := strings.Contains(result, `"error"`)
			if hasError != tt.wantError {
				t.Errorf("Call() hasError = %v, wantError %v", hasError, tt.wantError)
			}
		})
	}
}

func TestExecute(t *testing.T) {
	tests := []struct {
		name      string
		method    string
		params    map[string]interface{}
		wantError bool
	}{
		{
			name:   "Sum with valid params",
			method: "Sum",
			params: map[string]interface{}{
				"a": float64(5),
				"b": float64(3),
			},
			wantError: false,
		},
		{
			name:   "Sum with missing param",
			method: "Sum",
			params: map[string]interface{}{
				"a": float64(5),
			},
			wantError: true,
		},
		{
			name:   "Sum with wrong param type",
			method: "Sum",
			params: map[string]interface{}{
				"a": "not-a-number",
				"b": float64(3),
			},
			wantError: true,
		},
		{
			name:   "SumString",
			method: "SumString",
			params: map[string]interface{}{
				"a": "5",
				"b": "3",
			},
			wantError: false,
		},
		{
			name:      "Increase",
			method:    "Increase",
			params:    map[string]interface{}{},
			wantError: false,
		},
		{
			name:      "Unknown method",
			method:    "UnknownMethod",
			params:    map[string]interface{}{},
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := Execute(tt.method, tt.params)

			_, hasError := result["error"]
			if hasError != tt.wantError {
				t.Errorf("Execute() error = %v, wantError %v", hasError, tt.wantError)
				return
			}

			if !tt.wantError {
				if _, hasResult := result["result"]; !hasResult {
					t.Errorf("Execute() result not found in response map")
				}
			}
		})
	}
}
