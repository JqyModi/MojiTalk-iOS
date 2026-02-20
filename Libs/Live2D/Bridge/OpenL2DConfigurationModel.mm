//
//  OpenL2DConfigurationModel.m
//  MOJiKaiwa
//
//  Created by HaoXiang Lin on 2024/11/7.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import "OpenL2DConfigurationModel.h"
#import "L2DCacheManager.h"

@implementation OpenL2DConfigurationModel

- (BOOL)canLoad {
    return [self fileOrDirectoryExistsWithPath:self.modelDirPath];
}

- (BOOL)hasBackgroundImage {
    return [self fileOrDirectoryExistsWithPath:self.backgroundImagePath];
}

- (BOOL)fileOrDirectoryExistsWithPath:(NSString *)path {
    if (!path || [path length] == 0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}

- (BOOL)isLoad {
    return [[L2DCacheManager sharedInstance] getL2DModelCacheWithModelName:self.fileName] != nil;
}

- (void)preloadWithCompletion:(void (^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 设置模型加载路径和模型 JSON 名称
        NSString* modelJsonName = [NSString stringWithFormat:@"%@.model3.json", self.fileName];
        NSString* modelPath = self.modelDirPath;
        
        // 尝试加载live 2d model
        if ([[L2DCacheManager sharedInstance] getL2DModelCacheWithModelName:self.fileName] == nil) {
            L2DModel *model = new L2DModel();
            model->LoadAssets(modelPath, modelJsonName);
            [[L2DCacheManager sharedInstance] setL2DModelToCache:model withModelName:self.fileName];
        }
        // 加载背景图像
        if ([self hasBackgroundImage]) {
            TextureInfo* backgroundTexture = [L2DTextureHelper createTextureFromPngFile:[self.backgroundImagePath UTF8String]];
        }
        // 回到主线程调用回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(); // 调用回调并传递结果
            }
        });
    });
}

@end
