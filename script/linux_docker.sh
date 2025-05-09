#!/bin/bash
. "$(dirname $0)/env.sh"
# 检查 ROOT 环境变量是否已定义
echo "ROOT: $ROOT"
if [ -z "$ROOT" ]; then
  echo "请定义 ROOT 环境变量！"
  exit 1
fi

# 给容器指定一个名字
CONTAINER_NAME="go-dev"

# 获取容器状态
CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null >&2 || echo "not_exist")

case "$CONTAINER_STATUS" in
  "not_exist")
    echo "容器 '$CONTAINER_NAME' 不存在，正在创建并启动..."
    ;;
  *)
    echo "删除已存在的容器 '$CONTAINER_NAME'..."
    docker rm -f "$CONTAINER_NAME"
    ;;
esac

# 直接从 Dockerfile 构建并运行容器
docker build -t docker-build-temp -f "$ROOT/script/docker/u2004.Dockerfile" "$ROOT/script/docker" && \
docker run -i --rm --name "$CONTAINER_NAME" \
           --privileged=True \
           -v "$ROOT:/workspace" \
           docker-build-temp $@
if [ $? -ne 0 ]; then
  echo "错误：容器运行失败"
  exit 1
fi

echo "docker 打包成功完成"
