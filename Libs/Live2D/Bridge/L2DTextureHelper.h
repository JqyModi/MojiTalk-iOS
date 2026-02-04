/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#ifndef L2DTextureHelper_h
#define L2DTextureHelper_h

#import <string>

@interface L2DTextureHelper : NSObject

/**
 * @brief 纹理信息构造体
 */
typedef struct
{
    id <MTLTexture> id;              ///< 纹理向量ID
    int width;              ///< 宽
    int height;             ///< 高
    std::string fileName;       ///< 纹理文件名
}TextureInfo;

/**
 * @brief 创建纹理
 *
 * @param[in] fileName  纹理文件名
 * @return 创建纹理信息。创建失败时返回NULL
 */
+ (TextureInfo*) createTextureFromPngFile:(std::string)fileName;


@end
#endif /* L2DTextureHelper_h */
