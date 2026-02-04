/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DAudioManager.h"
#import <AVFoundation/AVAudioSession.h>
#import "L2DWavFileHandler.h"
#import "L2DPal.h"
// #import "MOJiDefaultsManager.h"

using namespace Csm;

namespace {
    void PrepareAudioSessionWithPronunciationMode() {
        AVAudioSession *session = AVAudioSession.sharedInstance;
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers error:&error];
        [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    }
}

csmBool L2DAudioManager::LoadFile(Csm::csmString path, Csm::csmUint32 useChannel, NSString *targetKey)
{
    // 如果正在播放相同的文件，则暂停播放
    if (_currentFilePath == path && _isPlaying) {
        StopAndReleaseAsync();
        OnAudioStopNotification(targetKey);
        _isLoadFile = false;
        return true;
    }
    
    // 如果正在播放不同的文件，先停止当前播放
    StopAndReleaseAsync();

    
    // 记录当前播放的文件路径
    _currentFilePath = path;
    _isPaused = false;
    _isPlaying = true;
    
    // 初期化
    _isLoadFile = true;
    
    _targetKey = targetKey;

    PrepareAudioSessionWithPronunciationMode();
    AudioStreamBasicDescription format;
    AudioQueueBufferRef buffers[L2DDefine::AudioQueueBufferCount];
    OSStatus status;
     
    // WAVファイルをロード
    L2DWavFileHandler wavHandler;
    wavHandler.Start(path);
    L2DWavFileHandler::WavFileInfo wavHandlerInfo = wavHandler.GetWavFileInfo();
    _wavSamples = wavHandler.GetPcmData();
    
    // リングバッファ確保
    _buffer.Resize(L2DDefine::CsmRingBufferSize * wavHandlerInfo._blockAlign);
    
    // 再生設定
    format.mSampleRate = wavHandlerInfo._samplingRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
    format.mBitsPerChannel = sizeof(csmFloat32) * 8;
    format.mChannelsPerFrame = wavHandlerInfo._numberOfChannels;
    format.mBytesPerFrame = sizeof(csmFloat32) * format.mChannelsPerFrame;
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mBytesPerFrame * format.mFramesPerPacket;
    format.mReserved = 0;
    
    _channels = wavHandlerInfo._numberOfChannels;
    _bitDepth = wavHandlerInfo._bitsPerSample;
    _queueBufferSize = L2DDefine::AudioQueueBufferSampleCount * format.mBytesPerFrame;
    _queueBufferSampleCount = L2DDefine::AudioQueueBufferSampleCount;
    _wavWritePos = 0;
    
    if (_useChannel < _channels)
    {
        _useChannel = useChannel;
    }
    else
    {
        _useChannel = _channels - 1;
    }
    
    
    status = AudioQueueNewOutput(&format, CallBackForAudioFile, this, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_outputQueue);
    
    if (status != noErr)
    {
        L2DPal::PrintLogLn("[APP]Failed to AudioQueueNewOutput() in L2DAudioManager::LoadFile()");
        return false;
    }
    
    
    for (csmUint32 i = 0; i < L2DDefine::AudioQueueBufferCount; i++)
    {
        status = AudioQueueAllocateBuffer(_outputQueue, _queueBufferSize, &buffers[i]);
                
        if (status != noErr)
        {
            L2DPal::PrintLogLn("[APP]Failed to AudioQueueAllocateBuffer() in L2DAudioManager::LoadFile()");
            return false;
        }
        
        buffers[i]->mAudioDataByteSize = _queueBufferSize;
        
        // キューをキックして音を鳴らす。
        CallBackForAudioFile(this, _outputQueue, buffers[i]);
    }
    
    // 设置播放速度
    if (_outputQueue) {
        // 启用变速播放
        UInt32 enableTimePitch = 1;
        AudioQueueSetProperty(_outputQueue, kAudioQueueProperty_EnableTimePitch, &enableTimePitch, sizeof(enableTimePitch));
        AudioQueueSetParameter(_outputQueue, kAudioQueueParam_PlayRate, _playbackSpeed);
    }
    
    // 音声再生
    status = AudioQueueStart(_outputQueue, NULL);
    
    if (status != noErr)
    {
        _isPlaying = false;
        L2DPal::PrintLogLn("[APP]Failed to AudioQueueStart() in L2DAudioManager::LoadFile()");
        return false;
    }
    
    AudioQueueSetParameter(_outputQueue, kAudioQueueParam_Volume, 1.0f);
    
    return true;
}

MotionSync::CubismMotionSyncAudioBuffer<csmFloat32>* L2DAudioManager::GetBuffer()
{
    return &_buffer;
}

csmBool L2DAudioManager::IsPlay()
{
    if (!_isLoadFile)
    {
        return true;
    }

    return _wavSamples.GetSize() > _wavWritePos;
}

L2DAudioManager::L2DAudioManager() :
    _queueBufferSize(0),
    _queueBufferSampleCount(0),
    _wavWritePos(0),
    _useChannel(0),
    _channels(1),
    _bitDepth(8),
    _buffer(),
    _isLoadFile(false),
    _playbackSpeed(1.0f),
    _isPaused(false),
    _isPlaying(false),
    _rmsPower(0.0f)
{
}

L2DAudioManager::~L2DAudioManager()
{
    StopAndReleaseAsync();
}

void L2DAudioManager::CallBackForAudioFile(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer)
{
    L2DAudioManager* data = reinterpret_cast<L2DAudioManager*>(customData);
    csmFloat32 *samples = reinterpret_cast<csmFloat32*>(buffer->mAudioData);
    
    if (data->_wavSamples.GetSize() <= data->_wavWritePos)
    {
        data->OnAudioStopNotification(data->_targetKey);
        return;
    }
    
    for (csmUint64 i = 0; i < data->_queueBufferSampleCount * data->_channels; i++)
    {
        if (data->_wavWritePos < data->_wavSamples.GetSize())
        {
            samples[i] = data->_wavSamples[data->_wavWritePos++];
        }
        else
        {
            samples[i] = 0.0f;
        }

        // 解析に指定しているチャンネルのサンプルを送る。
        if ((i % 2) == data->_useChannel)
        {
            data->_buffer.AddValue(samples[i]);
        }
    }

    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);

    // 计算 RMS 功率作为口型同步的参考
    float sum = 0.0f;
    for (csmUint64 i = 0; i < data->_queueBufferSampleCount; i++) {
        float val = samples[i * data->_channels + data->_useChannel];
        sum += val * val;
    }
    float rms = (data->_queueBufferSampleCount > 0) ? sqrtf(sum / data->_queueBufferSampleCount) : 0.0f;
    
    // 简单的平滑处理
    data->_rmsPower = data->_rmsPower * 0.7f + rms * 0.3f;
}

void L2DAudioManager::OnAudioStopNotification(NSString *targetKey)
{
    _currentFilePath = "";

    dispatch_async(dispatch_get_main_queue(), ^{
        // Removed notification logic
    });
    
}

void L2DAudioManager::InputCallBackForMicrophone(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer, const AudioTimeStamp *startTime, UInt32 packetNum, const AudioStreamPacketDescription *packetDesc)
{
    L2DAudioManager* data = reinterpret_cast<L2DAudioManager*>(customData);
    csmFloat32 *samples = reinterpret_cast<csmFloat32*>(buffer->mAudioData);
    if (0 < packetNum)
    {
        data->WriteInputBuffer(samples);
    }
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

void L2DAudioManager::OutputCallBackForMicrophone(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer)
{
    L2DAudioManager* data = reinterpret_cast<L2DAudioManager*>(customData);
    csmFloat32 *samples = reinterpret_cast<csmFloat32*>(buffer->mAudioData);

    data->ReadInputBuffer(samples);
    
    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
}

void L2DAudioManager::WriteInputBuffer(csmFloat32* samples)
{
    _mutex.Lock();
    
    if (_inputQueue)
    {
        // マイク入力の内容を受け取る。
        csmVector<csmFloat32> inputData;
        for (csmUint32 i = 0; i < _queueBufferSampleCount * _channels; i++)
        {
            inputData.PushBack(samples[i]);
        }
        _inputDataList.AddValue(inputData);
    }
    
    _mutex.Unlock();
}

void L2DAudioManager::ReadInputBuffer(csmFloat32* samples)
{
    _mutex.Lock();
    
    if (0 < _inputDataList.GetSize())
    {
        // 録音した音声を送る。
        for (csmUint32 i = 0; i < _queueBufferSampleCount * _channels && i < _inputDataList[0].GetSize(); i++)
        {
            samples[i] = _inputDataList[0][i];
            
            // 解析に指定しているチャンネルのサンプルを送る。
            if ((i % 2) == _useChannel)
            {
                _buffer.AddValue(samples[i]);
            }
        }
        _inputDataList.Remove(1);
    }
    else
    {
        for (csmUint32 i = 0; i < _queueBufferSampleCount * _channels; i++)
        {
            samples[i] = 0.0f;
        }
    }
    
    _mutex.Unlock();
}

void L2DAudioManager::SetPlaybackSpeed(float speed)
{
    if (speed <= 0.0f) {
        speed = 1.0f;  // 确保速度不为0或负数
    }
    _playbackSpeed = speed;
    
    // 更新 AudioQueue 的播放速度
    if (_outputQueue) {
        OSStatus status = AudioQueueSetParameter(_outputQueue, kAudioQueueParam_PlayRate, _playbackSpeed);
        if (status != noErr) {
            L2DPal::PrintLogLn("[APP]Failed to set playback speed: %d", status);
        }
        
        // 启用变速播放
        UInt32 enableTimePitch = 1;
        status = AudioQueueSetProperty(_outputQueue, kAudioQueueProperty_EnableTimePitch, &enableTimePitch, sizeof(enableTimePitch));
        if (status != noErr) {
            L2DPal::PrintLogLn("[APP]Failed to enable time pitch: %d", status);
        }
    } else {
        L2DPal::PrintLogLn("[APP]Cannot set playback speed: AudioQueue is not initialized");
    }
}

float L2DAudioManager::GetPlaybackSpeed() const
{
    return _playbackSpeed;
}

void L2DAudioManager::Pause()
{
    if (_outputQueue && _isPlaying) {
        AudioQueuePause(_outputQueue);
        _isPaused = true;
        _isPlaying = false;
    }
}

void L2DAudioManager::Resume()
{
    if (_outputQueue && _isPaused) {
        AudioQueueStart(_outputQueue, NULL);
        _isPaused = false;
        _isPlaying = true;
    }
}

void L2DAudioManager::StopAndReleaseAsync() {
    _isPlaying = false;
    _isPaused = false;
    _wavWritePos = _wavSamples.GetSize();

    AudioQueueRef inputQueue = _inputQueue;
    AudioQueueRef outputQueue = _outputQueue;
    _inputQueue = nullptr;
    _outputQueue = nullptr;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (inputQueue) {
            AudioQueueStop(inputQueue, true);
            AudioQueueDispose(inputQueue, true);
        }
        if (outputQueue) {
            AudioQueueStop(outputQueue, true);
            AudioQueueDispose(outputQueue, true);
        }
    });
}

bool L2DAudioManager::IsPlaying() const
{
    return _isPlaying;
}

Csm::csmString L2DAudioManager::GetCurrentFilePath() const
{
    return _currentFilePath;
}

float L2DAudioManager::GetRmsPower()
{
    return _rmsPower;
}
