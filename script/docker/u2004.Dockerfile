# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai

# 更新系统并安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    xz-utils \
    make \
    # CGO 开发必需
    gcc \
    g++ \
    libc6-dev \
    # 清理缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Go
ENV GO_VERSION=1.24.3
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

# 设置 Go 环境变量
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/developer/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# 创建用户 developer (UID=1000)
RUN useradd -m -u 1000 -s /bin/bash developer \
    && echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 创建工作目录
RUN mkdir -p /workspace && chown developer:developer /workspace

# 切换到 developer 用户
USER developer
WORKDIR /workspace

# 创建 Go 工作目录
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin ${GOPATH}/pkg

# 创建并设置 entrypoint 脚本
USER root
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 切换回 developer 用户
USER developer

# 设置 entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["echo", "构建完成"]
