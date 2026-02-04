//
//  MOJiMTKView.h
//  MOJiLive2D
//
//  Created by HaoXiang Lin on 2024/10/28.
//

#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MOJiL2DConfigurationModel;

@interface MOJiMTKView : MTKView

- (instancetype)initWithConfigurationModel:(nullable MOJiL2DConfigurationModel *)model;

- (void)loadAndPlayAudioFile:(NSString *)filePath targetKey:(NSString *)targetKey;

- (void)setAudioPlaybackSpeed:(float)speed;

- (void)stopPlayAudio;

@end

NS_ASSUME_NONNULL_END
