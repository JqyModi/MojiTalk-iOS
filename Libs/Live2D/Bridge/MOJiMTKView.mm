//
//  MOJiMTKView.m
//  MOJiLive2D
//
//  Created by HaoXiang Lin on 2024/10/28.
//

#import "MOJiMTKView.h"
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"
#import "L2DDefine.h"
#import "Math/CubismMatrix44.hpp"
#import "Math/CubismViewMatrix.hpp"
#import "L2DPal.h"
#import "L2DSprite.h"
#import "MOJiL2DConfigurationModel.h"
#import "L2DTextureHelper.h"
#import "L2DCacheManager.h"
#import "L2DRenderer.h"

using namespace L2DDefine;

@interface MOJiMTKView()<MTKViewDelegate>
{
    /// 当前帧的时间
    double _currentFrame;
    /// 计算两帧之间的时间差
    float _deltaTime;
    /// 上一帧时间
    double _lastFrame;
}
@property (nonatomic, nullable) id<MTLCommandQueue> commandQueue;
@property (nonatomic) id<MTLTexture> depthTexture;
@property (nonatomic) Csm::CubismViewMatrix *viewMatrix;
// 用于设备到屏幕的矩阵
@property (nonatomic) Csm::CubismMatrix44 *deviceToScreen;
// 背景图片
@property (nonatomic) L2DSprite *back;
// live 2d 相关配置model
@property (nonatomic, strong) MOJiL2DConfigurationModel *configurationModel;
// 渲染器
@property (nonatomic, strong) L2DRenderer *renderer;

@end

@implementation MOJiMTKView

- (instancetype)initWithConfigurationModel:(nullable MOJiL2DConfigurationModel *)model {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.delegate = self;
        self.framebufferOnly = YES;
        self.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
        _currentFrame = [[NSDate date] timeIntervalSince1970];
        _deltaTime = 0.0f;
        _lastFrame = [[NSDate date] timeIntervalSince1970];

        // 初始化设备到屏幕的坐标转换矩阵
        _deviceToScreen = new CubismMatrix44();
        // 初始化视图矩阵，用于管理屏幕内容的缩放和平移
        _viewMatrix = new CubismViewMatrix();
        // 初始化渲染器
        _renderer = [[L2DRenderer alloc]initWithConfigurationModel:model];
        // 设置图层的像素格式为 BGRA8Unorm，并让其支持透明
        CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
        metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        metalLayer.opaque = NO;
        
        // 获取系统默认 Metal 设备
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        metalLayer.device = device;
        // 创建 Metal 命令队列
        _commandQueue = [device newCommandQueue];
        
        // 将 Metal 图层注册到 Cubism 渲染实例中
        [[CubismRenderingInstanceSingleton_Metal sharedManager] setMetalLayer:metalLayer];

        // 调用初始化屏幕的自定义方法
        [self initializeScreen];
        
        if (model != nil && [model canLoad]) {
            self.configurationModel = model;
            [self loadLive2D];
        }
    }
    return self;
}

// 初始化屏幕相关设置
- (void)initializeScreen
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];  // 获取屏幕边界
    int width = screenRect.size.width;
    int height = screenRect.size.height;

    // 基于垂直尺寸的比例
    float ratio = static_cast<float>(width) / static_cast<float>(height);
    float left = -ratio;
    float right = ratio;
    float bottom = ViewLogicalLeft;
    float top = ViewLogicalRight;

    // 设置屏幕的显示区域
    _viewMatrix->SetScreenRect(left, right, bottom, top);
    _viewMatrix->Scale(ViewScale, ViewScale);

    _deviceToScreen->LoadIdentity();  // 重新设置矩阵为单位矩阵
    if (width > height)
    {
        float screenW = fabsf(right - left);
        _deviceToScreen->ScaleRelative(screenW / width, -screenW / width);
    }
    else
    {
        float screenH = fabsf(top - bottom);
        _deviceToScreen->ScaleRelative(screenH / height, -screenH / height);
    }
    _deviceToScreen->TranslateRelative(-width * 0.5f, -height * 0.5f);

    // 设置最大和最小缩放比例
    _viewMatrix->SetMaxScale(ViewMaxScale); // 最大缩放比例
    _viewMatrix->SetMinScale(ViewMinScale); // 最小缩放比例

    // 设置最大可显示区域
    _viewMatrix->SetMaxScreenRect(
                                  ViewLogicalMaxLeft,
                                  ViewLogicalMaxRight,
                                  ViewLogicalMaxBottom,
                                  ViewLogicalMaxTop
                                  );
}

- (void)loadLive2D {
    // 设置模型加载路径和模型 JSON 名称
    NSString* modelJsonName = [NSString stringWithFormat:@"%@.model3.json", self.configurationModel.fileName];
    NSString* modelPath = self.configurationModel.modelDirPath;
    
    __weak MOJiMTKView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 尝试加载live 2d model (耗时 IO 操作)
        if ([[L2DCacheManager sharedInstance] getL2DModelCacheWithModelName:weakSelf.configurationModel.fileName] == nil) {
            L2DModel *model = new L2DModel();
            model->LoadAssets(modelPath, modelJsonName);
            [[L2DCacheManager sharedInstance] setL2DModelToCache:model withModelName:weakSelf.configurationModel.fileName];
        }
        
        // 加载背景图像 (耗时操作)
        if ([weakSelf.configurationModel hasBackgroundImage]) {
            TextureInfo* backgroundTexture = [L2DTextureHelper createTextureFromPngFile:[weakSelf.configurationModel.backgroundImagePath UTF8String]];
            
            // 回到主线程更新 UI 相关状态
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf) return;
                float x = weakSelf.frame.size.width * 0.5f;
                float y = weakSelf.frame.size.height * 0.5f;
                float fWidth = static_cast<float>(backgroundTexture->width);
                float fHeight = static_cast<float>(backgroundTexture->height);
                
                CGSize displaySize = [weakSelf backGroundImageDisplaySizeWithImageSize:CGSizeMake(fWidth, fHeight)];
                weakSelf.back = [[L2DSprite alloc] initWithMyVar:x Y:y Width:displaySize.width Height:displaySize.height MaxWidth:weakSelf.frame.size.width MaxHeight:weakSelf.frame.size.height Texture:backgroundTexture->id];
            });
        }
        // 加载完成后回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.onLoadingComplete) {
                weakSelf.onLoadingComplete();
            }
        });
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resizeScreen];
    
    if (_back) {
        float x = self.frame.size.width * 0.5f;
        float y = self.frame.size.height * 0.5f;
        float fWidth = static_cast<float>(_back.GetTextureId.width);// * 0.6f;
        float fHeight = static_cast<float>(_back.GetTextureId.height);// * 0.6f;
        
        CGSize displaySize = [self backGroundImageDisplaySizeWithImageSize:CGSizeMake(fWidth, fHeight)];

        [_back resizeImmidiate:x Y:y Width:displaySize.width Height:displaySize.height MaxWidth:self.frame.size.width MaxHeight:self.frame.size.height];
    }
}

- (CGSize)backGroundImageDisplaySizeWithImageSize:(CGSize)imageSize{
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    CGFloat frameAspectRatio = self.bounds.size.width / self.bounds.size.height;
    
    CGFloat E, F;
    
    if (frameAspectRatio < imageAspectRatio) {
        F = self.bounds.size.height;
        E = F * imageAspectRatio;
    } else {
        E = self.bounds.size.width;
        F = E / imageAspectRatio;
    }
    return CGSizeMake(E, F);
}

// 处理屏幕调整时的操作
- (void)resizeScreen
{
    float width = self.frame.size.width;
    float height = self.frame.size.height;

    // 同样基于垂直尺寸的比例调整
    float ratio = width / height ;
    float left = -ratio;
    float right = ratio;
    float bottom = ViewLogicalLeft;
    float top = ViewLogicalRight;

    // 设置屏幕显示区域
    _viewMatrix->SetScreenRect(left, right, bottom, top);
    _viewMatrix->Scale(ViewScale, ViewScale);

    _deviceToScreen->LoadIdentity();  // 重置矩阵
    if (width > height)
    {
        float screenW = fabsf(right - left);
        _deviceToScreen->ScaleRelative(screenW / width, -screenW / width);
    }
    else
    {
        float screenH = fabsf(top - bottom);
        _deviceToScreen->ScaleRelative(screenH / height, -screenH / height);
    }
    _deviceToScreen->TranslateRelative(-width * 0.5f, -height * 0.5f);

    // 设置最大最小缩放比例
    _viewMatrix->SetMaxScale(ViewMaxScale);
    _viewMatrix->SetMinScale(ViewMinScale);

    // 设置最大可显示区域
    _viewMatrix->SetMaxScreenRect(
                                  ViewLogicalMaxLeft,
                                  ViewLogicalMaxRight,
                                  ViewLogicalMaxBottom,
                                  ViewLogicalMaxTop
                                  );
}

//MARK: - MTKViewDelegate
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    MTLTextureDescriptor* depthTextureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:size.width height:size.height mipmapped:false];
    depthTextureDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    depthTextureDescriptor.storageMode = MTLStorageModePrivate;

    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id <MTLDevice> device = [single getMTLDevice];
    _depthTexture = [device newTextureWithDescriptor:depthTextureDescriptor];

    [self resizeScreen];  // 调整屏幕
}

- (void)drawInMTKView:(MTKView *)view {
    [self updateTime];  // 更新时间

    id <MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];  // 获取 Metal 命令缓冲区
    id<CAMetalDrawable> currentDrawable = [view currentDrawable];  // 获取可绘制内容

    if (!currentDrawable) {
        return;
    }
    
    MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0);

    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    // 渲染模型之外的内容
    [self renderSprite:renderEncoder];

    [renderEncoder endEncoding];  // 结束编码
    
    // 设置视图矩阵
    [_renderer setViewMatrix:_viewMatrix];
    // 更新 Live2D 模型
    [_renderer onUpdate:commandBuffer currentDrawable:currentDrawable depthTexture:_depthTexture displaySize:view.bounds.size deltaTime:_deltaTime];

    [commandBuffer presentDrawable:currentDrawable];  // 呈现可绘制内容
    [commandBuffer commit];  // 提交命令缓冲区
}

- (void)renderSprite:(id<MTLRenderCommandEncoder>)renderEncoder
{
    if (_back) {
        [_back renderImmidiate:renderEncoder];  // 渲染背景图像
    }
}

/// 更新时间
- (void)updateTime {
    NSDate *now = [NSDate date];
    double currentTime = [now timeIntervalSince1970]; // 获取当前 Unix 时间
    _currentFrame = currentTime; // 当前帧的时间
    _deltaTime = _currentFrame - _lastFrame;
    _lastFrame = _currentFrame; // 更新上一帧时间
}

- (void)loadAndPlayAudioFile:(NSString *)filePath targetKey:(NSString *)targetKey{
    [_renderer loadAndPlayAudioFile:filePath targetKey:targetKey];
}

- (void)setAudioPlaybackSpeed:(float)speed {
    [_renderer setAudioPlaybackSpeed:speed];
}

- (void)stopPlayAudio {
    [_renderer stopPlayAudio];
}

- (void)setPreferredFPS:(NSInteger)fps {
    self.preferredFramesPerSecond = fps;
}

- (void)dealloc {
    if (_deviceToScreen) {
        delete _deviceToScreen;
        _deviceToScreen = nil;
    }
    if (_viewMatrix) {
        delete _viewMatrix;
        _viewMatrix = nil;
    }
}

@end
