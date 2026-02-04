//
//  L2DModel.h
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef L2DModel_h
#define L2DModel_h

#import "CubismFramework.hpp"
#import "Model/CubismUserModel.hpp"
#import "CubismMotionSync.hpp"
#import "CubismModelMotionSyncSettingJson.hpp"
#import "Type/csmRectF.hpp"
#import "Rendering/Metal/CubismOffscreenSurface_Metal.hpp"
#import "L2DAudioManager.h"

/**
 * @brief 用户实际使用的模型实现类
 *        负责模型生成、功能组件生成、更新处理和渲染调用。
 *
 */
class L2DModel : public Csm::CubismUserModel
{
public:
    /**
     * @brief 构造函数
     */
    L2DModel();

    /**
     * @brief 析构函数
     */
    virtual ~L2DModel();

    /**
     * @brief 从 model3.json 所在的目录和文件路径生成模型
     *
     */
    void LoadAssets(NSString* dir, NSString* fileName);

    /**
     * @brief 重新构建渲染器
     */
    void ReloadRenderer();

    /**
     * @brief 模型的更新处理。根据模型的参数确定绘制状态。
     * @param[in]   deltaTime     增量时间
     */
    void Update(const Float32 deltaTime);

    /**
     * @brief 绘制模型。将模型绘制到给定的 View-Projection 矩阵空间中。
     *
     * @param[in]  matrix  View-Projection 矩阵
     */
    void Draw(Csm::CubismMatrix44& matrix);

    /**
     * @brief 开始播放指定的动作
     *
     * @param[in]   group                       动作组名
     * @param[in]   no                          组内编号
     * @param[in]   priority                    优先级
     * @param[in]   onFinishedMotionHandler     动作播放结束时的回调函数。若为 NULL 则不调用。
     * @return                                  返回启动的动作的识别编号。无法启动时返回 -1。
     */
    Csm::CubismMotionQueueEntryHandle StartMotion(const Csm::csmChar* group, Csm::csmInt32 no, Csm::csmInt32 priority, Csm::ACubismMotion::FinishedMotionCallback onFinishedMotionHandler = NULL);

    /**
     * @brief 随机选择并开始播放动作组中的一个动作
     *
     * @param[in]   group                       动作组名
     * @param[in]   priority                    优先级
     * @param[in]   onFinishedMotionHandler     动作播放结束时的回调函数。若为 NULL 则不调用。
     * @return                                  返回启动的动作的识别编号。无法启动时返回 -1。
     */
    Csm::CubismMotionQueueEntryHandle StartRandomMotion(const Csm::csmChar* group, Csm::csmInt32 priority, Csm::ACubismMotion::FinishedMotionCallback onFinishedMotionHandler = NULL);

    /**
     * @brief 设置指定的表情动作
     *
     * @param   expressionID    表情动作的 ID
     */
    void SetExpression(const Csm::csmChar* expressionID);

    /**
     * @brief 随机选择并设置表情动作
     */
    void SetRandomExpression();

    /**
     * @brief 接收事件的触发
     */
    virtual void MotionEventFired(const Live2D::Cubism::Framework::csmString& eventValue);

    /**
     * @brief 碰撞检测
     *        从指定 ID 的顶点列表计算矩形，并判断坐标是否在矩形范围内。
     *
     * @param[in]   hitAreaName     需要测试碰撞的 ID
     * @param[in]   x               进行判定的 X 坐标
     * @param[in]   y               进行判定的 Y 坐标
     */
    virtual Csm::csmBool HitTest(const Csm::csmChar* hitAreaName, Csm::csmFloat32 x, Csm::csmFloat32 y);

    /**
     * @brief 获取用于在其他目标上绘制的缓冲区
     */
    Csm::Rendering::CubismOffscreenSurface_Metal& GetRenderBuffer();

    /**
     * @brief 检查 .moc3 文件的完整性
     *
     * @param[in]   mocName MOC3 文件名
     * @return      如果 MOC3 文件一致，返回 true；否则返回 false。
     */
    Csm::csmBool HasMocConsistencyFromFile(const Csm::csmChar* mocFileName);

    void playAudio(NSString *path, NSString *targetKey);

    void stopPlayAudio();
    
    /**
     * @brief 设置音频播放速度
     * @param speed 播放速度 (1.0 为正常速度)
     */
    void SetAudioPlaybackSpeed(float speed);
    
    /**
     * @brief 获取当前音频播放速度
     * @return 当前播放速度
     */
    float GetAudioPlaybackSpeed() const;

protected:
    /**
     * @brief 执行绘制模型的操作
     */
    void DoDraw();

private:
    /**
     * @brief 从 model3.json 生成模型
     *        根据 model3.json 中的描述生成模型、动作、物理效果等组件。
     *
     * @param[in]   setting     ICubismModelSetting 实例
     */
    void SetupModel(Csm::MotionSync::CubismModelMotionSyncSettingJson* setting);

    /**
     * @brief 加载纹理到 Metal 渲染器中
     */
    void SetupTextures();

    /**
     * @brief 根据动作组名预加载所有动作
     *
     * @param[in]   group  动作组名
     */
    void PreloadMotionGroup(const Csm::csmChar* group);

    /**
     * @brief 释放指定动作组的所有动作
     *
     * @param[in]   group  动作组名
     */
    void ReleaseMotionGroup(const Csm::csmChar* group) const;

    /**
     * @brief 释放所有加载的动作数据
     */
    void ReleaseMotions();

    /**
     * @brief 释放所有加载的表情数据
     */
    void ReleaseExpressions();

    Csm::csmString _modelHomeDir; ///< 模型文件所在的目录路径
    Csm::csmFloat32 _userTimeSeconds; ///< 时间增量（以秒为单位）
    Csm::csmVector<Csm::CubismIdHandle> _eyeBlinkIds; ///< 眨眼功能的参数 ID
    Csm::csmVector<Csm::CubismIdHandle> _lipSyncIds; ///< 唇形同步的参数 ID
    Csm::csmMap<Csm::csmString, Csm::ACubismMotion*> _motions; ///< 加载的动作列表
    Csm::csmMap<Csm::csmString, Csm::ACubismMotion*> _expressions; ///< 加载的表情列表
    Csm::csmVector<Csm::csmRectF> _hitArea; ///< 碰撞区域
    Csm::csmVector<Csm::csmRectF> _userArea; ///< 用户区域
    const Csm::CubismId* _idParamAngleX; ///< 参数 ID: ParamAngleX
    const Csm::CubismId* _idParamAngleY; ///< 参数 ID: ParamAngleY
    const Csm::CubismId* _idParamAngleZ; ///< 参数 ID: ParamAngleZ
    const Csm::CubismId* _idParamBodyAngleX; ///< 参数 ID: ParamBodyAngleX
    const Csm::CubismId* _idParamEyeBallX; ///< 参数 ID: ParamEyeBallX
    const Csm::CubismId* _idParamEyeBallY; ///< 参数 ID: ParamEyeBallY

    Live2D::Cubism::Framework::Rendering::CubismOffscreenSurface_Metal _renderBuffer; ///< 渲染缓冲区
    
    Csm::MotionSync::CubismModelMotionSyncSettingJson* _modelSetting;

    Csm::MotionSync::CubismMotionSync* _motionSync; ///< モーションシンク
    
    L2DAudioManager _soundData;
};

#endif /* L2DModel_h */
