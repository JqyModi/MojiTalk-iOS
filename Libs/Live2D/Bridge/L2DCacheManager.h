//
//  L2DCacheManager.h
//  MOJiKaiwa
//
//  Created by 林浩翔 on 2024/11/7.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L2DTextureHelper.h"
#import "L2DModel.h"

NS_ASSUME_NONNULL_BEGIN
/// 用于存放L2D纹理和模型加载的管理单例(降低重复加载的耗时)
/// 后续可以在这里增加缓存最大上限的设置
@interface L2DCacheManager: NSObject

+ (instancetype)sharedInstance;
/// 获取已经加载的纹理,找不到则返回nil
- (nullable TextureInfo *)getTextureCacheWithfileName:(std::string)fileName;
/// 存入已经加载的纹理
- (void)setTextureToCache:(TextureInfo *)textureInfo;
/// 获取已经加载的模型,找不到则返回nil
- (nullable L2DModel *)getL2DModelCacheWithModelName:(NSString *)modelName;
/// 存入已经加载的模型
- (void)setL2DModelToCache:(L2DModel *)model withModelName:(NSString *)modelName;
@end

NS_ASSUME_NONNULL_END
