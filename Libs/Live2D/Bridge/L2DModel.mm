//
//  L2DModel.m
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

#import "L2DModel.h"
#import <Foundation/Foundation.h>
#import <fstream>
#import <vector>
#import "L2DDefine.h"
#import "L2DPal.h"
#import "L2DTextureHelper.h"
#import "CubismDefaultParameterId.hpp"
#import "CubismModelSettingJson.hpp"
#import "Id/CubismIdManager.hpp"
#import "Motion/CubismMotion.hpp"
#import "Motion/CubismMotionQueueEntry.hpp"
#import "Physics/CubismPhysics.hpp"
#import "Rendering/Metal/CubismRenderer_Metal.hpp"
#import "Utils/CubismString.hpp"
#import "L2DCacheManager.h"
#import "CubismModelMotionSyncSettingJson.hpp"

using namespace Live2D::Cubism::Framework;
using namespace Live2D::Cubism::Framework::DefaultParameterId;
using namespace L2DDefine;
using namespace MotionSync;

namespace {
    // 从文件路径创建缓冲区
    csmByte* CreateBuffer(const csmChar* path, csmSizeInt* size)
    {
        if (DebugLogEnable)
        {
            L2DPal::PrintLogLn("[APP]create buffer: %s ", path);
        }
        return L2DPal::LoadFileAsBytes(path,size);
    }

    // 释放缓冲区以防止内存泄漏
    void DeleteBuffer(csmByte* buffer, const csmChar* path = "")
    {
        if (DebugLogEnable)
        {
            L2DPal::PrintLogLn("[APP]delete buffer: %s", path);
        }
        L2DPal::ReleaseBytes(buffer);
    }
}

L2DModel::L2DModel()
: CubismUserModel()
, _modelSetting(NULL)
, _motionSync(NULL)
, _userTimeSeconds(0.0f)
{
    // 启用一致性验证
    if (MocConsistencyValidationEnable)
    {
        _mocConsistency = true;
    }

    // 启用调试模式
    if (DebugLogEnable)
    {
        _debugMode = true;
    }

    // 初始化参数 ID
    _idParamAngleX = CubismFramework::GetIdManager()->GetId(ParamAngleX);
    _idParamAngleY = CubismFramework::GetIdManager()->GetId(ParamAngleY);
    _idParamAngleZ = CubismFramework::GetIdManager()->GetId(ParamAngleZ);
    _idParamBodyAngleX = CubismFramework::GetIdManager()->GetId(ParamBodyAngleX);
    _idParamEyeBallX = CubismFramework::GetIdManager()->GetId(ParamEyeBallX);
    _idParamEyeBallY = CubismFramework::GetIdManager()->GetId(ParamEyeBallY);
}

L2DModel::~L2DModel()
{
    // 销毁渲染缓冲区
    _renderBuffer.DestroyOffscreenSurface();

    // 释放动作和表情资源
    ReleaseMotions();
    ReleaseExpressions();

    // 释放每个动作组的资源
    for (csmInt32 i = 0; i < _modelSetting->GetMotionGroupCount(); i++)
    {
        const csmChar* group = _modelSetting->GetMotionGroupName(i);
        ReleaseMotionGroup(group);
    }

    // 释放模型设定
    if (_modelSetting)
    {
        delete _modelSetting;
    }

    // 释放MotionSync
    if (_motionSync)
    {
        _soundData.StopAndReleaseAsync();
        CubismMotionSync::Delete(_motionSync);
    }
}

// 加载模型的资产
void L2DModel::LoadAssets(NSString* dir, NSString* fileName)
{
    
    _modelHomeDir = [[NSString stringWithFormat:@"%@/", dir] UTF8String];

    NSString *jsonFilePath = [NSString stringWithFormat:@"%@/%@", dir, fileName];
    
    NSURL *url = [NSURL fileURLWithPath: jsonFilePath];
    // Read json file.
    NSData* data = [NSData dataWithContentsOfURL: url];

    if (data == nil || data.length < 0) {
        NSLog(@"Live2d model json文件读取失败,文件路径为: %@",jsonFilePath);
        return;
    }

    //加载模型设置
    CubismModelMotionSyncSettingJson* setting = new CubismModelMotionSyncSettingJson((const unsigned char *)[data bytes],
                                                              (unsigned int)[data length]);

    // 设置模型
    SetupModel(setting);

    // 如果模型加载失败，输出错误日志
    if (_model == NULL)
    {
        L2DPal::PrintLogLn("Failed to LoadAssets().");
        return;
    }

    // 创建渲染器并设置纹理
    CreateRenderer();
    SetupTextures();
}

// 设置模型的相关资源
void L2DModel::SetupModel(CubismModelMotionSyncSettingJson* setting)
{
    _updating = true;
    _initialized = false;
    _modelSetting = setting;

    csmByte* buffer;
    csmSizeInt size;
    
    // 加载 Cubism 模型
    if (strcmp(_modelSetting->GetModelFileName(), "") != 0)
    {
        csmString path = _modelSetting->GetModelFileName();
        path = _modelHomeDir + path;

        if (_debugMode)
        {
            L2DPal::PrintLogLn("[APP]create model: %s", setting->GetModelFileName());
        }

        buffer = CreateBuffer(path.GetRawString(), &size);
        LoadModel(buffer, size, _mocConsistency);  // 加载模型
        DeleteBuffer(buffer, path.GetRawString());
    }
    
    const csmChar* fileName = _modelSetting->GetMotionSyncJsonFileName();

    if (strcmp(fileName, ""))
    {
        const csmString path = csmString(_modelHomeDir) + fileName;
        buffer = CreateBuffer(path.GetRawString(), &size);

        _motionSync = CubismMotionSync::Create(_model, buffer, size, SamplesPerSec);

        if (!_motionSync)
        {
            DeleteBuffer(buffer, path.GetRawString());
            return;
        }

        // 将音频管理器的 buffer 与 MotionSync 关联
        _motionSync->SetSoundBuffer(0, _soundData.GetBuffer());

        DeleteBuffer(buffer, path.GetRawString());
    }

    // 加载表情、物理文件、姿势、呼吸等
    if (_modelSetting->GetExpressionCount() > 0)
    {
        const csmInt32 count = _modelSetting->GetExpressionCount();
        for (csmInt32 i = 0; i < count; i++)
        {
            csmString name = _modelSetting->GetExpressionName(i);
            csmString path = _modelSetting->GetExpressionFileName(i);
            path = _modelHomeDir + path;

            buffer = CreateBuffer(path.GetRawString(), &size);
            ACubismMotion* motion = LoadExpression(buffer, size, name.GetRawString());

            if (motion)
            {
                if (_expressions[name] != NULL)
                {
                    ACubismMotion::Delete(_expressions[name]);
                    _expressions[name] = NULL;
                }
                _expressions[name] = motion;
            }

            DeleteBuffer(buffer, path.GetRawString());
        }
    }

    // 加载物理数据
    if (strcmp(_modelSetting->GetPhysicsFileName(), "") != 0)
    {
        csmString path = _modelSetting->GetPhysicsFileName();
        path = _modelHomeDir + path;

        buffer = CreateBuffer(path.GetRawString(), &size);
        LoadPhysics(buffer, size);
        DeleteBuffer(buffer, path.GetRawString());
    }

    // 加载姿势数据
    if (strcmp(_modelSetting->GetPoseFileName(), "") != 0)
    {
        csmString path = _modelSetting->GetPoseFileName();
        path = _modelHomeDir + path;

        buffer = CreateBuffer(path.GetRawString(), &size);
        LoadPose(buffer, size);
        DeleteBuffer(buffer, path.GetRawString());
    }

    // 初始化眨眼和呼吸数据
    if (_modelSetting->GetEyeBlinkParameterCount() > 0)
    {
        _eyeBlink = CubismEyeBlink::Create(_modelSetting);
    }

    // 初始化呼吸参数
    {
        _breath = CubismBreath::Create();
        csmVector<CubismBreath::BreathParameterData> breathParameters;

        breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleX, 0.0f, 15.0f, 6.5345f, 0.5f));
        breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleY, 0.0f, 8.0f, 3.5345f, 0.5f));
        breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamAngleZ, 0.0f, 10.0f, 5.5345f, 0.5f));
        breathParameters.PushBack(CubismBreath::BreathParameterData(_idParamBodyAngleX, 0.0f, 4.0f, 15.5345f, 0.5f));
        breathParameters.PushBack(CubismBreath::BreathParameterData(CubismFramework::GetIdManager()->GetId(ParamBreath), 0.5f, 0.5f, 3.2345f, 0.5f));

        _breath->SetParameters(breathParameters);  // 设置呼吸参数
    }

    // 加载用户自定义数据
    if (strcmp(_modelSetting->GetUserDataFile(), "") != 0)
    {
        csmString path = _modelSetting->GetUserDataFile();
        path = _modelHomeDir + path;
        buffer = CreateBuffer(path.GetRawString(), &size);
        LoadUserData(buffer, size);
        DeleteBuffer(buffer, path.GetRawString());
    }

    // 获取眨眼 ID
    {
        csmInt32 eyeBlinkIdCount = _modelSetting->GetEyeBlinkParameterCount();
        for (csmInt32 i = 0; i < eyeBlinkIdCount; ++i)
        {
            _eyeBlinkIds.PushBack(_modelSetting->GetEyeBlinkParameterId(i));
        }
    }

    // 获取唇同步 ID
    {
        csmInt32 lipSyncIdCount = _modelSetting->GetLipSyncParameterCount();
        if (lipSyncIdCount > 0)
        {
            for (csmInt32 i = 0; i < lipSyncIdCount; ++i)
            {
                _lipSyncIds.PushBack(_modelSetting->GetLipSyncParameterId(i));
            }
        }
        else
        {
            // 如果 model3.json 中没有配置，默认添加标准口型参数 ParamMouthOpenY
            _lipSyncIds.PushBack(CubismFramework::GetIdManager()->GetId(ParamMouthOpenY));
        }
    }

    if (_modelSetting == NULL || _modelMatrix == NULL)
    {
        L2DPal::PrintLogLn("Failed to SetupModel().");
        return;
    }

    // 设置布局
    csmMap<csmString, csmFloat32> layout;
    _modelSetting->GetLayoutMap(layout);
    _modelMatrix->SetupFromLayout(layout);

    _model->SaveParameters();

    // 预加载所有动作组
    for (csmInt32 i = 0; i < _modelSetting->GetMotionGroupCount(); i++)
    {
        const csmChar* group = _modelSetting->GetMotionGroupName(i);
        PreloadMotionGroup(group);
    }

    _motionManager->StopAllMotions();

    _updating = false;
    _initialized = true;
}

// 预加载动作组
void L2DModel::PreloadMotionGroup(const csmChar* group)
{
    const csmInt32 count = _modelSetting->GetMotionCount(group);

    for (csmInt32 i = 0; i < count; i++)
    {
        // ex) idle_0
        csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, i);
        csmString path = _modelSetting->GetMotionFileName(group, i);
        path = _modelHomeDir + path;

        if (_debugMode)
        {
            L2DPal::PrintLogLn("[APP]load motion: %s => [%s_%d] ", path.GetRawString(), group, i);
        }

        csmByte* buffer;
        csmSizeInt size;
        buffer = CreateBuffer(path.GetRawString(), &size);
        CubismMotion* tmpMotion = static_cast<CubismMotion*>(LoadMotion(buffer, size, name.GetRawString()));

        if (tmpMotion)
        {
            csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, i);
            if (fadeTime >= 0.0f)
            {
                tmpMotion->SetFadeInTime(fadeTime);
            }

            fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, i);
            if (fadeTime >= 0.0f)
            {
                tmpMotion->SetFadeOutTime(fadeTime);
            }
            tmpMotion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);

            if (_motions[name] != NULL)
            {
                ACubismMotion::Delete(_motions[name]);
            }
            _motions[name] = tmpMotion;
        }

        DeleteBuffer(buffer, path.GetRawString());
    }
}

// 释放动作组资源
void L2DModel::ReleaseMotionGroup(const csmChar* group) const
{
    const csmInt32 count = _modelSetting->GetMotionCount(group);
    for (csmInt32 i = 0; i < count; i++)
    {
        csmString voice = _modelSetting->GetMotionSoundFileName(group, i);
        if (strcmp(voice.GetRawString(), "") != 0)
        {
            csmString path = voice;
            path = _modelHomeDir + path;
        }
    }
}

// 释放动作
void L2DModel::ReleaseMotions()
{
    for (csmMap<csmString, ACubismMotion*>::const_iterator iter = _motions.Begin(); iter != _motions.End(); ++iter)
    {
        ACubismMotion::Delete(iter->Second);
    }

    _motions.Clear();
}

// 释放表情
void L2DModel::ReleaseExpressions()
{
    for (csmMap<csmString, ACubismMotion*>::const_iterator iter = _expressions.Begin(); iter != _expressions.End(); ++iter)
    {
        ACubismMotion::Delete(iter->Second);
    }

    _expressions.Clear();
}

// 更新模型状态
void L2DModel::Update(const Float32 deltaTime)
{
    _userTimeSeconds += deltaTime;

    _dragManager->Update(deltaTime);
    _dragX = _dragManager->GetX();
    _dragY = _dragManager->GetY();

    // 更新动画状态
    csmBool motionUpdated = false;

    _model->LoadParameters();  // 加载参数
    if (_motionManager->IsFinished())
    {
        // 如果没有动作播放，启动随机待机动作
        StartRandomMotion(MotionGroupIdle, PriorityIdle);
    }
    else
    {
        motionUpdated = _motionManager->UpdateMotion(_model, deltaTime);  // 更新动作
    }
    _model->SaveParameters();  // 保存参数

    // 更新眨眼
    if (!motionUpdated)
    {
        if (_eyeBlink != NULL)
        {
            _eyeBlink->UpdateParameters(_model, deltaTime);
        }
    }

    // 更新表情
    if (_expressionManager != NULL)
    {
        _expressionManager->UpdateMotion(_model, deltaTime);
    }

    // 更新拖拽参数
    _model->AddParameterValue(_idParamAngleX, _dragX * 30);
    _model->AddParameterValue(_idParamAngleY, _dragY * 30);
    _model->AddParameterValue(_idParamAngleZ, _dragX * _dragY * -30);

    _model->AddParameterValue(_idParamBodyAngleX, _dragX * 10);
    _model->AddParameterValue(_idParamEyeBallX, _dragX);
    _model->AddParameterValue(_idParamEyeBallY, _dragY);

    // 更新呼吸
    if (_breath != NULL)
    {
        _breath->UpdateParameters(_model, deltaTime);
    }

    // 更新物理效果
    if (_physics != NULL)
    {
        _physics->Evaluate(_model, deltaTime);
    }

    if (_soundData.IsPlay()) {
        const float power = _soundData.GetRmsPower();
        // 将 RMS 映射到 [0, 1] 范围。通常 RMS 在 0.05~0.2 之间，乘以 6-8 倍比较合适
        float value = power * 7.0f; 
        if (value > 1.0f) value = 1.0f;
        
        // 动态设置唇形参数
        for (csmUint32 i = 0; i < _lipSyncIds.GetSize(); ++i) {
            _model->SetParameterValue(_lipSyncIds[i], value); 
        }
    }
 else {
        // 停止播放时，确保嘴巴闭合
        for (csmUint32 i = 0; i < _lipSyncIds.GetSize(); ++i) {
            _model->SetParameterValue(_lipSyncIds[i], 0.0f);
        }
    }
    
    // 更新姿势
    if (_pose != NULL)
    {
        _pose->UpdateParameters(_model, deltaTime);
    }

    _model->Update();
}

// 启动特定动作
CubismMotionQueueEntryHandle L2DModel::StartMotion(const csmChar* group, csmInt32 no, csmInt32 priority, ACubismMotion::FinishedMotionCallback onFinishedMotionHandler)
{
    if (priority == PriorityForce)
    {
        _motionManager->SetReservePriority(priority);
    }
    else if (!_motionManager->ReserveMotion(priority))
    {
        if (_debugMode)
        {
            L2DPal::PrintLogLn("[APP]can't start motion.");
        }
        return InvalidMotionQueueEntryHandleValue;
    }

    const csmString fileName = _modelSetting->GetMotionFileName(group, no);

    // ex) idle_0
    csmString name = Utils::CubismString::GetFormatedString("%s_%d", group, no);
    CubismMotion* motion = static_cast<CubismMotion*>(_motions[name.GetRawString()]);
    csmBool autoDelete = false;

    // 如果动作不存在，加载新动作
    if (motion == NULL)
    {
        csmString path = fileName;
        path = _modelHomeDir + path;

        csmByte* buffer;
        csmSizeInt size;
        buffer = CreateBuffer(path.GetRawString(), &size);
        motion = static_cast<CubismMotion*>(LoadMotion(buffer, size, NULL, onFinishedMotionHandler));

        if (motion)
        {
            // 设置渐入和渐出时间
            csmFloat32 fadeTime = _modelSetting->GetMotionFadeInTimeValue(group, no);
            if (fadeTime >= 0.0f)
            {
                motion->SetFadeInTime(fadeTime);
            }

            fadeTime = _modelSetting->GetMotionFadeOutTimeValue(group, no);
            if (fadeTime >= 0.0f)
            {
                motion->SetFadeOutTime(fadeTime);
            }
            motion->SetEffectIds(_eyeBlinkIds, _lipSyncIds);
            autoDelete = true;  // 动作结束后自动删除
        }

        DeleteBuffer(buffer, path.GetRawString());
    }
    else
    {
        motion->SetFinishedMotionHandler(onFinishedMotionHandler);
    }

    // 播放音效（如果存在）
    csmString voice = _modelSetting->GetMotionSoundFileName(group, no);
    if (strcmp(voice.GetRawString(), "") != 0)
    {
        csmString path = voice;
        path = _modelHomeDir + path;
    }

    if (_debugMode)
    {
        L2DPal::PrintLogLn("[APP]start motion: [%s_%d]", group, no);
    }

    return  _motionManager->StartMotionPriority(motion, autoDelete, priority);
}

// 启动随机动作
CubismMotionQueueEntryHandle L2DModel::StartRandomMotion(const csmChar* group, csmInt32 priority, ACubismMotion::FinishedMotionCallback onFinishedMotionHandler)
{
    if (_modelSetting->GetMotionCount(group) == 0)
    {
        return InvalidMotionQueueEntryHandleValue;
    }

    // 随机选择一个动作编号
    csmInt32 no = rand() % _modelSetting->GetMotionCount(group);

    return StartMotion(group, no, priority, onFinishedMotionHandler);
}

// 使用 Metal 渲染器进行绘制
void L2DModel::DoDraw()
{
    if (_model == NULL)
    {
        return;
    }

    GetRenderer<Rendering::CubismRenderer_Metal>()->DrawModel();
}

// 将矩阵应用于模型并绘制
void L2DModel::Draw(CubismMatrix44& matrix)
{
    if (_model == NULL)
    {
        return;
    }

    matrix.MultiplyByMatrix(_modelMatrix);

    GetRenderer<Rendering::CubismRenderer_Metal>()->SetMvpMatrix(&matrix);

    DoDraw();
}

// 碰撞检测，判断是否点击到特定区域
csmBool L2DModel::HitTest(const csmChar* hitAreaName, csmFloat32 x, csmFloat32 y)
{
    // 如果模型不透明度小于 1，表示不可点击
    if (_opacity < 1)
    {
        return false;
    }

    // 检测指定区域是否被点击
    const csmInt32 count = _modelSetting->GetHitAreasCount();
    for (csmInt32 i = 0; i < count; i++)
    {
        if (strcmp(_modelSetting->GetHitAreaName(i), hitAreaName) == 0)
        {
            const CubismIdHandle drawID = _modelSetting->GetHitAreaId(i);
            return IsHit(drawID, x, y);
        }
    }

    return false;
}

// 设置表情
void L2DModel::SetExpression(const csmChar* expressionID)
{
    ACubismMotion* motion = _expressions[expressionID];
    if (_debugMode)
    {
        L2DPal::PrintLogLn("[APP]expression: [%s]", expressionID);
    }

    if (motion != NULL)
    {
        _expressionManager->StartMotionPriority(motion, false, PriorityForce);
    }
    else
    {
        if (_debugMode)
        {
            L2DPal::PrintLogLn("[APP]expression[%s] is null ", expressionID);
        }
    }
}

// 设置随机表情
void L2DModel::SetRandomExpression()
{
    if (_expressions.GetSize() == 0)
    {
        return;
    }

    // 随机选择一个表情
    csmInt32 no = rand() % _expressions.GetSize();
    csmMap<csmString, ACubismMotion*>::const_iterator map_ite;
    csmInt32 i = 0;
    for (map_ite = _expressions.Begin(); map_ite != _expressions.End(); map_ite++)
    {
        if (i == no)
        {
            csmString name = (*map_ite).First;
            SetExpression(name.GetRawString());
            return;
        }
        i++;
    }
}

// 重新加载渲染器
void L2DModel::ReloadRenderer()
{
    DeleteRenderer();

    CreateRenderer();

    SetupTextures();
}

// 设置模型纹理
void L2DModel::SetupTextures()
{
    for (csmInt32 modelTextureNumber = 0; modelTextureNumber < _modelSetting->GetTextureCount(); modelTextureNumber++)
    {
        // 如果纹理名为空，跳过加载
        if (!strcmp(_modelSetting->GetTextureFileName(modelTextureNumber), ""))
        {
            continue;
        }

        // 加载 Metal 纹理
        csmString texturePath = _modelSetting->GetTextureFileName(modelTextureNumber);
        
        texturePath = _modelHomeDir + texturePath;
        
        TextureInfo* texture = [L2DTextureHelper createTextureFromPngFile:texturePath.GetRawString()];
        id <MTLTexture> mtlTextueNumber = texture->id;

        // 将纹理绑定到渲染器
        GetRenderer<Rendering::CubismRenderer_Metal>()->BindTexture(modelTextureNumber, mtlTextueNumber);
    }

    GetRenderer<Rendering::CubismRenderer_Metal>()->IsPremultipliedAlpha(false);
}

// 当动作事件触发时调用
void L2DModel::MotionEventFired(const csmString& eventValue)
{
    CubismLogInfo("%s is fired on L2DModel!!", eventValue.GetRawString());
}

// 获取渲染缓冲区
Csm::Rendering::CubismOffscreenSurface_Metal& L2DModel::GetRenderBuffer()
{
    return _renderBuffer;
}

// 验证 MOC 文件的一致性
csmBool L2DModel::HasMocConsistencyFromFile(const csmChar* mocFileName)
{
    CSM_ASSERT(strcmp(mocFileName, ""));

    csmByte* buffer;
    csmSizeInt size;

    csmString path = mocFileName;
    path = _modelHomeDir + path;

    buffer = CreateBuffer(path.GetRawString(), &size);

    // 验证 MOC 文件的一致性
    csmBool consistency = CubismMoc::HasMocConsistencyFromUnrevivedMoc(buffer, size);
    if (!consistency)
    {
        CubismLogInfo("Inconsistent MOC3.");
    }
    else
    {
        CubismLogInfo("Consistent MOC3.");
    }

    DeleteBuffer(buffer);

    return consistency;
}

void L2DModel::playAudio(NSString *path, NSString *targetKey)
{
    // 如果正在播放相同的音频，则暂停播放
    if (_soundData.GetCurrentFilePath() == [path UTF8String] && _soundData.IsPlaying()) {
        _soundData.StopAndReleaseAsync();
        _soundData.OnAudioStopNotification(targetKey);
        return;
    }
    
    // 加载并播放新的音频
    _soundData.LoadFile([path UTF8String], 0, targetKey);
    _motionSync->SetSoundBuffer(0, _soundData.GetBuffer());
}

void L2DModel::SetAudioPlaybackSpeed(float speed)
{
    _soundData.SetPlaybackSpeed(speed);
}

float L2DModel::GetAudioPlaybackSpeed() const
{
    return _soundData.GetPlaybackSpeed();
}

void L2DModel::stopPlayAudio() {
    _soundData.StopAndReleaseAsync();
}
