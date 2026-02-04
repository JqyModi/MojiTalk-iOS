/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DDefine.h"
#import <Foundation/Foundation.h>

namespace L2DDefine {

    using namespace Csm;

    // 画面相关定义 (视图缩放和逻辑坐标范围)
    const csmFloat32 ViewScale = 1.0f; // 默认视图缩放比例
    const csmFloat32 ViewMaxScale = 2.0f; // 最大缩放比例
    const csmFloat32 ViewMinScale = 0.8f; // 最小缩放比例

    const csmFloat32 ViewLogicalLeft = -1.0f; // 逻辑坐标的左边界
    const csmFloat32 ViewLogicalRight = 1.0f; // 逻辑坐标的右边界
    const csmFloat32 ViewLogicalBottom = -1.0f; // 逻辑坐标的下边界
    const csmFloat32 ViewLogicalTop = 1.0f; // 逻辑坐标的上边界

    const csmFloat32 ViewLogicalMaxLeft = -2.0f; // 最大左边界（扩展范围）
    const csmFloat32 ViewLogicalMaxRight = 2.0f; // 最大右边界（扩展范围）
    const csmFloat32 ViewLogicalMaxBottom = -2.0f; // 最大下边界（扩展范围）
    const csmFloat32 ViewLogicalMaxTop = 2.0f; // 最大上边界（扩展范围）

    // 模型相关定义------------------------------------------
    // 动作组的名称 (与外部定义文件 json 中的定义一致)
    const csmChar* MotionGroupIdle = "Idle"; // 待机动作
    const csmChar* MotionGroupTapBody = "TapBody"; // 轻点身体的动作

    // 碰撞区域的名称 (与外部定义文件 json 中的定义一致)
    const csmChar* HitAreaNameHead = "Head"; // 头部的碰撞区域
    const csmChar* HitAreaNameBody = "Body"; // 身体的碰撞区域

    // 动作的优先级常量
    const csmInt32 PriorityNone = 0; // 无优先级
    const csmInt32 PriorityIdle = 1; // 待机动作的优先级
    const csmInt32 PriorityNormal = 2; // 普通动作的优先级
    const csmInt32 PriorityForce = 3; // 强制动作的优先级

    // MOC3 文件一致性验证选项
    const csmBool MocConsistencyValidationEnable = true; // 启用 MOC3 的一致性验证

    // 调试日志选项
    const csmBool DebugLogEnable = true; // 启用调试日志
    const csmBool DebugTouchLogEnable = false; // 启用触摸事件的调试日志

    // Framework 日志输出级别设置
    const CubismFramework::Option::LogLevel CubismLoggingLevel = CubismFramework::Option::LogLevel_Verbose; // 详细日志级别

    const csmInt32 AudioQueueBufferCount = 3;
    const csmInt32 AudioQueueBufferSampleCount = 2048;
    const csmUint32 CsmInputBufferSize = 32;
    const csmUint32 CsmRingBufferSize = 4096;
    const csmInt32 Channels = 2;
    const csmInt32 SamplesPerSec = 48000;
    const csmInt32 BitDepth = 16;
}
