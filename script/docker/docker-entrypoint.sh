#!/bin/bash
set -e

cd /workspace

cd packages/native_add/go
make linux

# 执行传入的命令或者启动 bash
exec "$@" 