/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#pragma once

#import <AudioToolbox/AudioQueue.h>
#import "L2DDefine.h"
#import "CubismMotionSyncAudioBuffer.hpp"
#import "Type/csmString.hpp"
#import "Type/csmVector.hpp"
#import "L2DMutex.h"

class L2DAudioManager
{
public:
    /**
     * @brief 音声ファイル読み込み
     *
     * @param[in]   path    音声ファイル
     * @param[in]   useChannel    使用するチャンネル
     *
     * @return 読み込み結果
     */
    Csm::csmBool LoadFile(Csm::csmString path, Csm::csmUint32 useChannel, NSString *targetKey);

    /**
     * @brief マイク入力の初期化
     *
     * @return 初期化が成功したか
     */
    Csm::csmBool SetupMicrophone(Csm::csmUint32 channels, Csm::csmUint32 samplesRate, Csm::csmUint32 bitDepth, Csm::csmUint32 useChannel);

    /**
     * @brief 再生したバッファの格納先の設定
     *
     * @return バッファ
     */
    Csm::MotionSync::CubismMotionSyncAudioBuffer<Csm::csmFloat32>* GetBuffer();

    /**
     * @brief 再生中か確認
     *
     * @return 再生中か
     */
    Csm::csmBool IsPlay();

    /**
     * @brief コンストラクタ
     *
     * コンストラクタ。
     *
     */
    L2DAudioManager();

    /**
     * @brief デストラクタ
     *
     * デストラクタ。
     */
    virtual ~L2DAudioManager();

    /**
     * @brief 设置播放速度
     * @param speed 播放速度 (1.0 为正常速度)
     */
    void SetPlaybackSpeed(float speed);
    
    /**
     * @brief 获取当前播放速度
     * @return 当前播放速度
     */
    float GetPlaybackSpeed() const;
    
    /**
     * @brief 暂停播放
     */
    void Pause();
    
    /**
     * @brief 恢复播放
     */
    void Resume();
    
    /**
     * @brief 获取当前播放状态
     * @return true 正在播放，false 已暂停或停止
     */
    bool IsPlaying() const;
    
    /**
     * @brief 获取当前播放的文件路径
     * @return 当前播放的文件路径
     */
    Csm::csmString GetCurrentFilePath() const;
    
    void OnAudioStopNotification(NSString *targetKey);
    
    void StopAndReleaseAsync();

    /**
     * @brief 获取音频 RMS 功率 (用于口型同步)
     * @return 功率值 (0.0 ~ 1.0)
     */
    float GetRmsPower();

private:
    
    /**
     * @brief 音声ファイル再生用のコールバック処理
     *
     */
    static void CallBackForAudioFile(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer);
       
    /**
     * @brief マイク入力時の録音時コールバック処理
     *
     */
    static void InputCallBackForMicrophone(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer, const AudioTimeStamp *startTime, UInt32 packetNum, const AudioStreamPacketDescription *packetDesc);
    
    /**
     * @brief マイク入力時の再生時コールバック処理
     *
     */
    static void OutputCallBackForMicrophone(void* customData, AudioQueueRef queue, AudioQueueBufferRef buffer);

    /**
     * @brief マイク入力時の録音データをバッファに格納する
     *
     * @param[in]   samples 録音データ
     */
    void WriteInputBuffer(Csm::csmFloat32* samples);
    
    /**
     * @brief マイク入力時の録音データをバッファから取り出す
     *
     * @param[in]   samples 録音データの取り出し先
     */
    void ReadInputBuffer(Csm::csmFloat32* samples);

    AudioQueueRef _inputQueue;
    AudioQueueRef _outputQueue;
    Csm::csmUint32 _queueBufferSize;
    Csm::csmUint32 _queueBufferSampleCount;
    // 録音したデータ
    Csm::MotionSync::CubismMotionSyncAudioBuffer<Csm::csmVector<Csm::csmFloat32>> _inputDataList;
    // wavデータ
    Csm::csmVector<Csm::csmFloat32> _wavSamples;
    // wavデータ書き込み位置
    Csm::csmUint32 _wavWritePos;
    // 使用するチャンネル
    Csm::csmUint32 _useChannel;
    // 使用するチャンネル数
    Csm::csmInt32 _channels;
    // 使用するビット深度
    Csm::csmInt32 _bitDepth;
    // MotionSyncで使用するバッファ
    Csm::MotionSync::CubismMotionSyncAudioBuffer<Csm::csmFloat32> _buffer;
    // 音声ファイル読み込み済か
    Csm::csmBool _isLoadFile;
    // mutex
    L2DMutex _mutex;
    // 音频标识
    NSString *_targetKey;
    float _playbackSpeed; ///< 播放速度
    Csm::csmString _currentFilePath; ///< 当前播放的文件路径
    bool _isPaused; ///< 是否暂停
    bool _isPlaying; ///< 是否正在播放
    float _rmsPower; ///< 当前音频 RMS 功率
};
