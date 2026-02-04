//
//  L2DCacheManager.m
//  MOJiKaiwa
//
//  Created by 林浩翔 on 2024/11/7.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import "L2DCacheManager.h"
#import "Type/csmVector.hpp"

@interface L2DCacheModel: NSObject
@property (nonatomic) L2DModel *model;
@property (nonatomic, copy) NSString *modelName;
@end

@implementation L2DCacheModel
@end

@interface L2DCacheManager()
/// 用于存放Live2d模型的数组
@property (nonatomic) NSMutableArray<L2DCacheModel*> *models;
/// 用于存储纹理信息的向量
@property (nonatomic) Csm::csmVector<TextureInfo*> textures;

@end

@implementation L2DCacheManager

+ (instancetype)sharedInstance {
    static L2DCacheManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// MARK: live2d 纹理 相关
- (nullable TextureInfo *)getTextureCacheWithfileName:(std::string)fileName {
    // 检查是否已经加载了该纹理
    for (Csm::csmUint32 i = 0; i < _textures.GetSize(); i++)
    {
        if (_textures[i]->fileName == fileName)
        {
            return _textures[i]; // 返回已加载的纹理
        }
    }
    return nil;
}

- (void)setTextureToCache:(TextureInfo *)textureInfo {
    TextureInfo *tmp = [self getTextureCacheWithfileName:textureInfo->fileName];
    
    if (tmp == nil) {
        _textures.PushBack(textureInfo);
    }
}

// MARK: live2d model 相关
- (NSMutableArray<L2DCacheModel *> *)models {
    if (_models == nil) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (nullable L2DModel *)getL2DModelCacheWithModelName:(NSString *)modelName {
    for (int i = 0; i < self.models.count; i++) {
        if ([self.models[i].modelName isEqualToString:modelName]) {
            return self.models[i].model;
        }
    }
    return nil;
}

- (void)setL2DModelToCache:(L2DModel *)model withModelName:(NSString *)modelName {
    L2DModel *tmp = [self getL2DModelCacheWithModelName:modelName];
    
    if (tmp == nil) {
        L2DCacheModel *newModel = [[L2DCacheModel alloc]init];
        newModel.model = model;
        newModel.modelName = modelName;
        [self.models addObject:newModel];
    }
}

@end



