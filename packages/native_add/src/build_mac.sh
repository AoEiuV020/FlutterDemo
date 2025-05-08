#!/bin/bash

# 进入当前脚本所在目录
cd "$(dirname "$0")"

# 创建并进入build目录
mkdir -p build
cd build

# 配置cmake项目
cmake ..

# 构建项目
cmake --build .