/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DTextureHelper.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <iostream>
#define STBI_NO_STDIO
#define STBI_ONLY_PNG
#define STB_IMAGE_IMPLEMENTATION
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#pragma clang diagnostic pop
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"
#import "stb_image.h"
#import "L2DPal.h"
#import "L2DCacheManager.h"

@implementation L2DTextureHelper

// 从 PNG 文件创建纹理
+ (TextureInfo*) createTextureFromPngFile:(std::string)fileName
{
    TextureInfo *cacheTexture = [[L2DCacheManager sharedInstance] getTextureCacheWithfileName:fileName];
    // 检查是否已经加载了该纹理
    if (cacheTexture != nil) {
        return cacheTexture;
    }
    
    int width, height, channels;
    unsigned int size;
    unsigned char* png;
    unsigned char* address;

    // 从文件加载 PNG 数据到内存
    address = L2DPal::LoadFileAsBytes(fileName, &size);

    // 使用 stb_image 解析 PNG 数据
    png = stbi_load_from_memory(
                                address,
                                static_cast<int>(size),
                                &width,
                                &height,
                                &channels,
                                STBI_rgb_alpha);

    
    
    
    // 创建 Metal 纹理描述符
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm; // 设置像素格式
    textureDescriptor.width = width;
    textureDescriptor.height = height;
    
    // 不使用 Mipmap
    textureDescriptor.mipmapLevelCount = 1;
    
    // 获取 Metal 设备
    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id <MTLDevice> device = [single getMTLDevice];

    // 创建 Metal 纹理
    id<MTLTexture> texture = [device newTextureWithDescriptor:textureDescriptor];

    // 计算每行字节数
    NSUInteger bytesPerRow = 4 * width;

    // 设置纹理区域
    MTLRegion region = {
        { 0, 0, 0 },                   // MTLOrigin
        {(NSUInteger)width, (NSUInteger)height, 1} // MTLSize
    };

    // 将 PNG 数据复制到纹理中
    [texture replaceRegion:region
                mipmapLevel:0
                 withBytes:png
                bytesPerRow:bytesPerRow];

    // 释放 PNG 数据和文件缓冲区
    stbi_image_free(png);
    L2DPal::ReleaseBytes(address);

    // 创建 TextureInfo 并保存
    TextureInfo* textureInfo = new TextureInfo;
    textureInfo->fileName = fileName;
    textureInfo->width = (int)width;
    textureInfo->height = (int)height;
    textureInfo->id = texture;
    
    // 保存到L2DCacheManager中
    [[L2DCacheManager sharedInstance] setTextureToCache:textureInfo];

    return textureInfo; // 返回纹理信息
}

@end
