//
//  L2DRenderer.m
//  MOJiKaiwa
//
//  Created by 林浩翔 on 2024/11/8.
//  Copyright © 2024 Hugecore Information Technology (Guangzhou) Co.,Ltd. All rights reserved.
//

#import "L2DRenderer.h"
#import "Rendering/Metal/CubismRenderer_Metal.hpp"
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"
#import "OpenL2DConfigurationModel.h"
#import "L2DCacheManager.h"
#import "L2DPal.h"

@interface L2DRenderer()
//モデル描画に用いるView行列
@property (nonatomic) Csm::CubismMatrix44 *viewMatrix;

@property (nonatomic) Csm::Rendering::CubismOffscreenSurface_Metal* renderBuffer;

@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;

@property (nonatomic, weak, nullable) OpenL2DConfigurationModel *configurationModel;

@end

@implementation L2DRenderer

- (instancetype)initWithConfigurationModel:(nullable OpenL2DConfigurationModel *)model {
    self = [super init];
    if (self) {
        _renderBuffer = nil;
        // 初始化视图矩阵
        _viewMatrix = new Csm::CubismMatrix44();
        // 模型信息,弱引用
        _configurationModel = model;
        // 设置 Metal 渲染通道
        _renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
        _renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
        _renderPassDescriptor.colorAttachments[0].clearColor  = MTLClearColorMake(0.f, 0.f, 0.f, 0.f);
        _renderPassDescriptor.depthAttachment.loadAction      = MTLLoadActionClear;
        _renderPassDescriptor.depthAttachment.storeAction     = MTLStoreActionDontCare;
        _renderPassDescriptor.depthAttachment.clearDepth      = 1.0;

    }
    return self;
}

- (void)onUpdate:(nonnull id<MTLCommandBuffer>)commandBuffer currentDrawable:(nonnull id<CAMetalDrawable>)drawable depthTexture:(nonnull id<MTLTexture>)depthTarget displaySize:(CGSize)displaySize deltaTime:(float)deltaTime {
    
    if (!self.configurationModel) { return; }
    
    L2DModel *model = [[L2DCacheManager sharedInstance]getL2DModelCacheWithModelName:self.configurationModel.fileName];
    
    if (!model) { return; }
    
    float width = displaySize.width;
    float height = displaySize.height;

    Csm::CubismMatrix44 projection;

    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id<MTLDevice> device = [single getMTLDevice];

    _renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    _renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    _renderPassDescriptor.depthAttachment.texture = depthTarget;

    Csm::Rendering::CubismRenderer_Metal::StartFrame(device, commandBuffer, _renderPassDescriptor);

    if (model->GetModel() == NULL)
    {
        L2DPal::PrintLogLn("Failed to model->GetModel().");
        return;
    }
    
    // 设置缩放比例和偏移量
    if (model->GetModel()->GetCanvasWidth() > 1.0f && width < height)
    {
        projection.Scale(1.0f, static_cast<float>(width) / static_cast<float>(height));
    }
    else
    {
        projection.Scale(static_cast<float>(height) / static_cast<float>(width), 1.0f);
    }
    
    
    model->GetModelMatrix()->SetWidth(self.configurationModel.zoomSclae);
    
    float offsetX = self.configurationModel.offsetX;
    float offsetY = self.configurationModel.offsetY;

    projection.Translate(offsetX, offsetY);
    
    if (_viewMatrix != NULL)
    {
        projection.MultiplyByMatrix(_viewMatrix);
    }

    model->Update(deltaTime) ;
    model->Draw(projection);
}

// 设置视图矩阵
- (void)setViewMatrix:(Csm::CubismMatrix44*)m;
{
    for (int i = 0; i < 16; i++) {
        _viewMatrix->GetArray()[i] = m->GetArray()[i];
    }
}

- (nullable L2DModel *)getCurrentL2DModel {
    return [[L2DCacheManager sharedInstance] getL2DModelCacheWithModelName:self.configurationModel.fileName];
}

- (void)loadAndPlayAudioFile:(NSString *)filePath targetKey:(NSString *)targetKey {
    [self getCurrentL2DModel]->playAudio(filePath, targetKey);
}

- (void)setAudioPlaybackSpeed:(float)speed {
    [self getCurrentL2DModel]->SetAudioPlaybackSpeed(speed);
}

- (void)stopPlayAudio {
    [self getCurrentL2DModel]->stopPlayAudio();
}

- (void)dealloc {
    if (_viewMatrix) {
        delete _viewMatrix;
        _viewMatrix = nil;
    }
}

@end
