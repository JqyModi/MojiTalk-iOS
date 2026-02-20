//
//  L2DRenderer.h
//  MOJiKaiwa
//
//  Created by 林浩翔 on 2024/11/8.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Metal/Metal.h"
#import "MetalKit/MetalKit.h"
#import "Math/CubismMatrix44.hpp"
#import "Type/csmVector.hpp"

@class OpenL2DConfigurationModel;

NS_ASSUME_NONNULL_BEGIN

@interface L2DRenderer : NSObject

/**
 * @brief   构造方法
 *
 */
- (instancetype)initWithConfigurationModel:(nullable OpenL2DConfigurationModel *)model;

/**
 * @brief   更新屏幕时的处理
 *          进行模型更新处理和绘图处理
 */
- (void)onUpdate:(nonnull id<MTLCommandBuffer>)commandBuffer currentDrawable:(nonnull id<CAMetalDrawable>)drawable depthTexture:(nonnull id<MTLTexture>)depthTarget displaySize:(CGSize)displaySize deltaTime:(float)deltaTime;


/**
 * @brief   设置视图矩阵
 */
- (void)setViewMatrix:(Csm::CubismMatrix44*)m;

- (void)loadAndPlayAudioFile:(NSString *)filePath targetKey:(NSString *)targetKey;

- (void)setAudioPlaybackSpeed:(float)speed;

- (void)stopPlayAudio;

@end

NS_ASSUME_NONNULL_END
