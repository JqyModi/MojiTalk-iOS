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

### 5. 模拟器符号缺失：`_csmMotionSync_Analyze`
- **问题原因**：Live2D MotionSync 官方库（`.a`）提供的子架构不完整，导致在 x86_64 模拟器上链接失败。
- **解决方案**：手动提取 `iphoneos` 和 `iphonesimulator` 的架构，使用 `lipo` 工具合并为 Fat Library，并更新 Podspec 指向该合并库。

### 6. 运行时崩溃与编译错误：`cannot execute tool 'metal'`
- **问题原因**：
    - **编译期**：部分 Xcode 环境（如某些内部或受限环境）可能缺少 Metal Toolchain 组件，导致无法编译 `.metal` 文件，报错 `cannot execute tool 'metal'`。
    - **运行期**：`newDefaultLibrary` 默认从 App 主包寻找 Shader，而在 Framework 模式下 Shader 位于库内部。
- **解决方案**：
    - **最终方案**：将 Metal Shader 源码以字符串形式嵌入 `CubismShader_Metal.mm`，并在运行时使用 `newLibraryWithSource:options:error:` 进行实时编译。
    - **优点**：完美避开 Xcode 编译环境差异和组件缺失问题，无需在 Podspec 中包含 `.metal` 文件，且能确保 Shader 逻辑与库代码强绑定，彻底解决加载路径和工具链报错。

### 7. 口型同步 (Lip Sync) 无效或幅度过小
- **问题现象**：音频正常播放，但模型嘴巴不动，或者仅微弱颤动。
- **解决方案与排查步骤**：
    1. **关联音频缓冲区**：对于支持 **MotionSync** 的模型（如 Suzu），必须显式调用 `_motionSync->SetSoundBuffer(0, _soundData.GetBuffer())`。
    2. **强制覆盖动作 (Motion Overwrite)**：应使用 `SetParameterValue` 而非 `Add` 类方法，以确保音频功率能覆盖预录制动作的口型。
    3. **参数 ID 校验**：通过打印 `_model->GetParameterId(i)->GetString().GetRawString()` 确认模型实际使用的唇形 ID。
    4. **映射逻辑调整**：将 RMS 功率乘以 **7.0~10.0** 倍以增强视觉张力，并增加简单的平滑滤波防抖。

## 功能实现说明

### 1. 口型同步 (Lip Sync)
- **原理**：通过 `L2DAudioManager` 在播放音频时实时计算 PCM 数据的 **RMS (Root Mean Square) 功率**。
- **集成**：
    - 优先使用 Live2D 官方的 **MotionSync** 引擎（如果模型包含 `.motionsync3.json`）。
    - 兜底方案：如果模型未配置 MotionSync，会自动将音频功率映射到 `ParamMouthOpenY` 等口型参数，实现基础的音量驱动型口型同步。
- **调用**：通过 `Live2DController.shared.playAudio(filePath:targetKey:)` 触发。

## 如何验证编译与运行
1. 打开 `MojiTalk.xcworkspace`。
2. 选择 `MojiTalk` Scheme。
3. 选择真机或模拟器。
4. 执行 `Product -> Build`。
5. 运行查看 Live2D 模型加载情况。

## 注意事项
- 如果修改了 `MojiLive2D.podspec` 的结构（如增删文件、修改公开头文件范围），必须在终端执行 `pod install` 以同步工程配置。
- 修改 `Bridge/` 下的代码时，注意内存管理，部分金属渲染对象需要遵循 Live2D 的生命周期管理。
