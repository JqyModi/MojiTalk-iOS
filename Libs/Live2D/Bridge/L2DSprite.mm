/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DSprite.h"
#import <Foundation/Foundation.h>
#import "CubismFramework.hpp"
#import "Rendering/Metal/CubismRenderer_Metal.hpp"
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"

#define BUFFER_OFFSET(bytes) ((GLubyte *)NULL + (bytes))

@interface L2DSprite()

@property (nonatomic, readwrite) id <MTLTexture> texture; // Metal 纹理
@property (nonatomic) SpriteRect rect; // 定义矩形的结构体
@property (nonatomic) id <MTLBuffer> vertexBuffer; // 顶点缓冲区
@property (nonatomic) id <MTLBuffer> fragmentBuffer; // 片段缓冲区

@end

@implementation L2DSprite

typedef struct
{
    vector_float4 baseColor; // 定义基础颜色的结构体

} BaseColor;

// 初始化方法，接受位置、宽高、纹理等参数
- (id)initWithMyVar:(float)x Y:(float)y Width:(float)width Height:(float)height
            MaxWidth:(float)maxWidth MaxHeight:(float)maxHeight Texture:(id <MTLTexture>) texture
{
    self = [super self];

    if (self != nil)
    {
        // 设置矩形的边界
        _rect.left = (x - width * 0.5f);
        _rect.right = (x + width * 0.5f);
        _rect.up = (y + height * 0.5f);
        _rect.down = (y - height * 0.5f);
        _texture = texture;

        // 初始化颜色为白色 (1.0f)
        _spriteColorR = _spriteColorG = _spriteColorB = _spriteColorA = 1.0f;

        _pipelineState = nil;
        _vertexBuffer = nil;
        _fragmentBuffer = nil;

        // 获取 Metal 设备
        CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
        id <MTLDevice> device = [single getMTLDevice];

        // 设置 Metal 缓冲区
        [self SetMTLBuffer:device MaxWidth:maxWidth MaxHeight:maxHeight];

        // 设置 Metal 渲染管线
        [self SetMTLFunction:device];
    }

    return self;
}

// 资源释放
- (void)dealloc
{
    if (_pipelineState != nil)
    {
        _pipelineState = nil;
    }

    if (_vertexBuffer != nil)
    {
        _vertexBuffer = nil;
    }

    if (_fragmentBuffer != nil)
    {
        _fragmentBuffer = nil;
    }
}

// 即时渲染方法
- (void)renderImmidiate:(id<MTLRenderCommandEncoder>)renderEncoder
{
    float width = _rect.right - _rect.left;
    float height = _rect.up - _rect.down;

    // 设置纹理
    [renderEncoder setFragmentTexture:_texture atIndex:0];

    // 设置顶点缓冲区
    [renderEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [renderEncoder setVertexBuffer:_fragmentBuffer offset:0 atIndex:1];

    // 设置渲染管线状态
    [renderEncoder setRenderPipelineState:_pipelineState];

    // 设置宽高并传递到渲染管线
    vector_float2 metalUniforms = (vector_float2){width, height};
    [renderEncoder setVertexBytes:&metalUniforms length:sizeof(vector_float2) atIndex:2];

    // 设置基础颜色
    BaseColor uniform;
    uniform.baseColor = (vector_float4){ _spriteColorR, _spriteColorG, _spriteColorB, _spriteColorA };
    [renderEncoder setFragmentBytes:&uniform length:sizeof(BaseColor) atIndex:2];
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
}

// 调整矩形大小
- (void)resizeImmidiate:(float)x Y:(float)y Width:(float)width Height:(float)height MaxWidth:(float)maxWidth MaxHeight:(float)maxHeight
{
    // 设置新的矩形边界
    _rect.left = (x - width * 0.5f);
    _rect.right = (x + width * 0.5f);
    _rect.up = (y + height * 0.5f);
    _rect.down = (y - height * 0.5f);

    // 更新 Metal 缓冲区
    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id <MTLDevice> device = [single getMTLDevice];
    [self SetMTLBuffer:device MaxWidth:maxWidth MaxHeight:maxHeight];
}

// 判断点击位置是否在矩形内
- (bool)isHit:(float)pointX PointY:(float)pointY
{
    return (pointX >= _rect.left && pointX <= _rect.right &&
            pointY >= _rect.down && pointY <= _rect.up);
}

// 设置颜色
- (void)SetColor:(float)r g:(float)g b:(float)b a:(float)a
{
    _spriteColorR = r;
    _spriteColorG = g;
    _spriteColorB = b;
    _spriteColorA = a;
}

// 获取 Metal 着色器代码
- (NSString*)GetMetalShader {
    NSString *string =
    @"#include <metal_stdlib>\n"
    "using namespace metal;\n"
    "\n"
    "struct ColorInOut\n"
    "{\n"
    "    float4 position [[ position ]];\n"
    "    float2 texCoords;\n"
    "};\n"
    "\n"
    "struct BaseColor\n"
    "{\n"
    "    float4 color;\n"
    "};\n"
    "\n"
    "vertex ColorInOut vertexShader(constant float4 *positions [[ buffer(0) ]],\n"
    "                               constant float2 *texCoords [[ buffer(1) ]],\n"
    "                                        uint    vid       [[ vertex_id ]])\n"
    "{\n"
    "    ColorInOut out;\n"
    "    out.position = positions[vid];\n"
    "    out.texCoords = texCoords[vid];\n"
    "    return out;\n"
    "}\n"
    "\n"
    "fragment float4 fragmentShader(ColorInOut       in      [[ stage_in ]],\n"
    "                               texture2d<float> texture [[ texture(0) ]],\n"
    "                               constant BaseColor &uniform [[ buffer(2) ]])\n"
    "{\n"
    "    constexpr sampler colorSampler;\n"
    "    float4 color = texture.sample(colorSampler, in.texCoords) * uniform.color;\n"
    "    return color;\n"
    "}\n";
    return string;
}

// 设置 Metal 顶点缓冲区
- (void)SetMTLBuffer:(id <MTLDevice>)device MaxWidth:(float)maxWidth MaxHeight:(float)maxHeight
{
    vector_float4 positionVertex[] =
    {
        {(_rect.left  - maxWidth * 0.5f) / (maxWidth * 0.5f), (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f), 0, 1},
        {(_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f), (_rect.down - maxHeight * 0.5f) / (maxHeight * 0.5f), 0, 1},
        {(_rect.left  - maxWidth * 0.5f) / (maxWidth * 0.5f), (_rect.up   - maxHeight * 0.5f) / (maxHeight * 0.5f), 0, 1},
        {(_rect.right - maxWidth * 0.5f) / (maxWidth * 0.5f), (_rect.up   - maxHeight * 0.5f) / (maxHeight * 0.5f), 0, 1},
    };

    vector_float2 uvVertex[] =
    {
        {0.0f, 1.0f},
        {1.0f, 1.0f},
        {0.0f, 0.0f},
        {1.0f, 0.0f},
    };

    // 创建 Metal 缓冲区，存储顶点和纹理坐标
    _vertexBuffer = [device newBufferWithBytes:positionVertex
                                        length:sizeof(positionVertex)
                                        options:MTLResourceStorageModeShared];
    _fragmentBuffer = [device newBufferWithBytes:uvVertex
                                          length:sizeof(uvVertex)
                                          options:MTLResourceStorageModeShared];
}

// 设置 Metal 渲染管线
- (void)SetMTLFunction:(id <MTLDevice>)device
{
    MTLCompileOptions* compileOptions = [MTLCompileOptions new];
    compileOptions.languageVersion = MTLLanguageVersion2_1; // 设置 Metal 语言版本
    NSString* shader = [self GetMetalShader]; // 获取 Metal 着色器代码
    NSError* compileError;
    id<MTLLibrary> shaderLib = [device newLibraryWithSource:shader options:compileOptions error:&compileError];
    if (!shaderLib)
    {
        NSLog(@" ERROR: Couldnt create a Source shader library");
        return;
    }
    // 获取顶点和片段着色器
    id <MTLFunction> vertexProgram = [shaderLib newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentProgram = [shaderLib newFunctionWithName:@"fragmentShader"];

    // 设置渲染管线描述符
    [self SetMTLRenderPipelineDescriptor:device vertexProgram:vertexProgram fragmentProgram:fragmentProgram];
}

// 设置 Metal 渲染管线描述符
- (void)SetMTLRenderPipelineDescriptor:(id <MTLDevice>)device vertexProgram:(id <MTLFunction>)vertexProgram fragmentProgram:(id <MTLFunction>)fragmentProgram
{
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    // 设置渲染管线状态
    pipelineDescriptor.label = @"SpritePipeline";
    pipelineDescriptor.vertexFunction = vertexProgram;
    pipelineDescriptor.fragmentFunction = fragmentProgram;
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.colorAttachments[0].blendingEnabled = true;
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;

    [self SetMTLRenderPipelineState:device pipelineDescriptor:pipelineDescriptor];
}

// 设置 Metal 渲染管线状态
- (void)SetMTLRenderPipelineState:(id <MTLDevice>)device pipelineDescriptor:(MTLRenderPipelineDescriptor*)pipelineDescriptor
{
    NSError *error;
    if (_pipelineState == nil)
    {
        _pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    }

    if (!_pipelineState)
    {
        NSLog(@"ERROR: Failed aquiring pipeline state: %@", error);
        return;
    }
}
@end

