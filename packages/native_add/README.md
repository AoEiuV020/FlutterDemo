# native_add

Golang FFI 插件项目，用于 Flutter 跨平台开发

## 项目概述

本项目通过 Go 语言实现跨平台原生功能，编译为 android/ios/windows/linux/macos/web 全平台原生库供 Flutter 调用。

## 快速开始

### 测试环境
- Go 1.24.1
- Flutter 3.29.3
- Make 3.81
- 各平台构建工具（Android NDK、Xcode等）

### 构建命令
进入go项目目录 [./go/](./go/)，执行以下命令：
```bash
# 构建所有平台，ios/mac/windows/linux 需要在各自平台下执行，
make android
make ios
make windows
make linux
make macos
make web
```

## 平台集成指南

### 通用说明
- 所有构建产物位于 [./prebuild/](./prebuild/) 目录， 按照平台和架构命名放置
- 所有预编译库的名字都写死为插件名字，如 `libnative_add.so`，以便统一以及复用默认的 DynamicLibrary.open 代码，

### Android
修改 [./android/build.gradle](./android/build.gradle) 配置：
```gradle
android {
    sourceSets {
        main {
            jniLibs.srcDirs = ["${project.projectDir}/../prebuild/Android"]
        }
    }
}
```
[./go/Makefile](./go/Makefile) 中写死了 NDK_VERSION = 27.2.12479018 ，请根据实际情况修改

### iOS/macOS
修改 [./ios/native_add.podspec](./ios/native_add.podspec) 和 [./macos/native_add.podspec](./macos/native_add.podspec)
- 使用 `force_load` 加载静态库
- 修改后需清除 Flutter app 模块的 build 缓存

### Windows/Linux
修改 [./windows/CMakeLists.txt](./windows/CMakeLists.txt) 和 [./linux/CMakeLists.txt](./linux/CMakeLists.txt)
- 直接设置预编译库到 native_add_bundled_libraries ，不再需要原本的src,

### Web
1. 复制 `libnative_add.wasm` 和 `wasm_exec.js` 到 Flutter web 目录
2. 参考 [./example/web/index.html](./example/web/index.html) 配置 wasm 加载
- [./lib/go_web.dart](./lib/go_web.dart) 使用 extension 拓展 JSWindow 以便调用 go wasm 暴露出来的函数，
- [./lib/native_add_web.dart](./lib/native_add_web.dart) promise等各种js中的对象需要toDart使用，
