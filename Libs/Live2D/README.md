# Live2D SDK 模块化集成说明

本项目采用组件化方式集成了 Live2D Cubism SDK (Core & Framework) 以及 MotionSync 模块，并封装了 Objective-C 桥接层供 Swift 调用。

## 目录结构
- `Core/`: Live2D 核心库 (C 接口)
- `Framework/`: Live2D 官方 C++ 基础框架 (src/)
- `MotionSync/`: Live2D MotionSync 相关库与框架
- `Bridge/`: 本地编写的 Objective-C 桥接层 (L2DCubism, MOJiMTKView 等)
- `MojiLive2D.podspec`: 本地开发 Pod 配置文件

## 核心架构方案
由于 Live2D SDK 主要由 C++ 编写，而主项目使用 Swift，为了避免 Swift 直接调用 C++ 带来的编译复杂性和类型冲突，采用了以下架构：
1. **纯粹的 C++ 实现层**：SDK 原生代码。
2. **Objective-C++ 桥接层**：在 `Bridge/` 目录下编写 `.mm` 文件，封装 C++ 调用逻辑。
3. **干净的 Objective-C 接口层**：定义 `.h` 头文件，使用纯 OC 类型或前向声明（Forward Declaration），严禁在这些头文件中包含任何 C++ 符号（如 `<new>`, `std::string` 等）。
4. **Swift 调用层**：通过 CocoaPods 自动生成的 Module 直接 `import MojiLive2D` 调用。

## 遇到的问题与解决方案 (Troubleshooting)

### 1. 编译错误：`fatal error: 'new' file not found`
- **问题原因**：Swift 在尝试导入 `MojiLive2D` 模块时，Clang 扫描器扫描到了 SDK 的 C++ 头文件（如 `CubismFramework.hpp`）。由于 Swift 默认不支持 C++ Interop，导致编译器无法处理标准库包含。
- **解决方案**：在 `MojiLive2D.podspec` 中精确设置 `s.public_header_files`。仅公开 `L2DCubism.h`, `MOJiMTKView.h` 等纯 OC 接口。将所有 `.hpp` 和其他内部头文件设为私有（Project Headers）。

### 2. 头文件找不到：`'CubismFramework.hpp' file not found`
- **问题原因**：SDK 内部文件分散在多个子目录下，且大量使用了基于工程根目录的相对路径，在转为 Framework 构建后，路径解析失败。
- **解决方案**：
    - 更新 `pod_target_xcconfig` 中的 `HEADER_SEARCH_PATHS`，包含所有必要的 SDK 子目录。
    - 对 SDK 核心文件进行路径补丁（Path Patching），例如将 `#include "CubismFramework.hpp"` 改为相对路径 `#include "../CubismFramework.hpp"`。

### 3. 沙盒限制：`Sandbox: rsync(xxxx) deny(1) file-write-create`
- **问题原因**：Xcode 15+ 默认开启了脚本沙盒模式，导致 CocoaPods 在执行 `[CP] Embed Pods Frameworks` 脚本时无法写入生成的 App 包。
- **解决方案**：在 Xcode 工程设置（`.xcodeproj`）中，将 `ENABLE_USER_SCRIPT_SANDBOXING` 设置为 `NO`。

### 4. 模拟器编译冲突：`arm64` 符号冲突
- **问题原因**：SDK 提供的 `libLive2DCubismCore_fat.a` 有可能未包含最新的模拟器版 arm64 架构。
- **解决方案**：在 Podspec 中为模拟器 SDK 排除 `arm64` 架构：`'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'`。

## 如何验证编译
1. 打开 `MojiTalk.xcworkspace`。
2. 选择 `MojiTalk` Scheme。
3. 选择真机设备。
4. 执行 `Product -> Build`。

## 注意事项
- 如果修改了 `MojiLive2D.podspec` 的结构（如增删文件、修改公开头文件范围），必须在终端执行 `pod install` 以同步工程配置。
- 修改 `Bridge/` 下的代码时，注意内存管理，部分金属渲染对象需要遵循 Live2D 的生命周期管理。
