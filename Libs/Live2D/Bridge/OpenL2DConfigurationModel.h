//
//  OpenL2DConfigurationModel.h
//  MOJiKaiwa
//
//  Created by HaoXiang Lin on 2024/11/7.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Live2D的配置Model
@interface OpenL2DConfigurationModel : NSObject
/// 放大比例
@property (nonatomic,assign) float zoomSclae;
/// 中心偏离值X
@property (nonatomic,assign) float offsetX;
/// 中心偏离值Y
@property (nonatomic,assign) float offsetY;
/// model文件夹
@property (nonatomic,copy) NSString *modelDirPath;
/// model名称
@property (nonatomic,copy) NSString *fileName;
/// 背景图路径
@property (nonatomic,copy) NSString *backgroundImagePath;
/// 能否加载
@property (nonatomic,assign) BOOL canLoad;
/// 是否拥有背景图片
@property (nonatomic,assign) BOOL hasBackgroundImage;
/// 已经加载了
@property (nonatomic,assign) BOOL isLoad;
/// 预加载
- (void)preloadWithCompletion:(void (^)())completion;

@end

NS_ASSUME_NONNULL_END
