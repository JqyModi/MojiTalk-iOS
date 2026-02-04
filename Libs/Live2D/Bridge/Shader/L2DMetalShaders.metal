/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Metal shaders used for this sample
*/

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// 包含 Metal 着色器代码与调用 Metal API 的 C 代码之间共享的头文件
#include "L2DMetalShaderTypes.h"

// 正常光栅化数据结构体
struct NormalRasterizerData
{
    float4 position [[ position ]]; // 顶点位置
    float2 texCoord; // 纹理坐标 (v2f.texcoord)
};

// 带遮罩的光栅化数据结构体
struct MaskedRasterizerData
{
    float4 position [[ position ]]; // 顶点位置
    float2 texCoord; // 纹理坐标
    float4 myPos; // 顶点在剪裁矩阵下的位置
};

// 顶点着色器，用于设置遮罩
vertex MaskedRasterizerData
VertShaderSrcSetupMask(uint vertexID [[ vertex_id ]],
             constant float2 *vertexArray [[ buffer(MetalVertexInputIndexVertices) ]],
             constant float2 *uvArray [[ buffer(MetalVertexInputUVs) ]],
             constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]])
{
    MaskedRasterizerData out;
    float2 vert = vertexArray[vertexID];
    float2 uv = uvArray[vertexID];

    float4 pos = float4(vert.x, vert.y, 0.0, 1.0);
    out.position = uniforms.clipMatrix * pos; // 使用剪裁矩阵变换顶点位置
    out.myPos = uniforms.clipMatrix * pos;
    out.texCoord = uv;
    out.texCoord.y = 1.0 - out.texCoord.y; // 翻转 Y 轴

    return out;
}

// 片元着色器，用于设置遮罩
fragment float4
FragShaderSrcSetupMask(MaskedRasterizerData in [[stage_in]],
                       texture2d<float> texture [[ texture(0) ]],
                       constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                       sampler smp [[sampler(0)]])
{
    // 判断像素是否在遮罩区域内
    float isInside =
        step(uniforms.baseColor.x, in.myPos.x/in.myPos.w)
        * step(uniforms.baseColor.y, in.myPos.y/in.myPos.w)
        * step(in.myPos.x/in.myPos.w, uniforms.baseColor.z)
        * step(in.myPos.y/in.myPos.w, uniforms.baseColor.w);

    // 计算遮罩颜色并返回
    float4 gl_FragColor = float4(uniforms.channelFlag * texture.sample(smp, in.texCoord).a * isInside);
    return gl_FragColor;
}

////----- 顶点着色器 -----
//// Normal & Add & Mult 共通
vertex NormalRasterizerData
VertShaderSrc(uint vertexID [[ vertex_id ]],
              constant float2 *vertexArray [[ buffer(MetalVertexInputIndexVertices) ]],
              constant float2 *uvArray [[ buffer(MetalVertexInputUVs) ]],
             constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]])

{
    NormalRasterizerData out;
    float2 vert = vertexArray[vertexID];
    float2 uv = uvArray[vertexID];

    float4 pos = float4(vert.x, vert.y, 0.0, 1.0);
    out.position = uniforms.matrix * pos; // 使用矩阵变换顶点位置
    out.texCoord = uv;
    out.texCoord.y = 1.0 - out.texCoord.y; // 翻转 Y 轴

    return out;
}

//// 用于绘制已剪裁的内容的顶点着色器
vertex MaskedRasterizerData
VertShaderSrcMasked(uint vertexID [[ vertex_id ]],
            constant float2 *vertexArray [[ buffer(MetalVertexInputIndexVertices) ]],
            constant float2 *uvArray [[ buffer(MetalVertexInputUVs) ]],
            constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]])
{
    MaskedRasterizerData out;
    float2 vert = vertexArray[vertexID];
    float2 uv = uvArray[vertexID];

    float4 pos = float4(vert.x, vert.y, 0.0, 1.0);
    out.position = uniforms.matrix * pos;
    out.myPos = uniforms.clipMatrix * pos;
    out.myPos = float4(out.myPos.x, 1.0 - out.myPos.y, out.myPos.zw); // 调整 Y 轴位置
    out.texCoord = uv;
    out.texCoord.y = 1.0 - out.texCoord.y; // 翻转 Y 轴

    return out;
}

////----- 片元着色器 -----
//// Normal & Add & Mult 共通
fragment float4
FragShaderSrc(NormalRasterizerData in [[stage_in]],
              texture2d<float> texture [[ texture(0) ]],
              constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
              sampler smp [[sampler(0)]])
{
    float4 texColor = texture.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = texColor.rgb + uniforms.screenColor.rgb - (texColor.rgb * uniforms.screenColor.rgb);
    float4 color = texColor * uniforms.baseColor;
    float4 gl_FragColor = float4(color.rgb * color.a,  color.a);

    return gl_FragColor;
}

//// Normal & Add & Mult 共通（PremultipliedAlpha）
fragment float4
FragShaderSrcPremultipliedAlpha(MaskedRasterizerData in [[stage_in]],
                        texture2d<float> texture [[ texture(0) ]],
                        constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                        sampler smp [[sampler(0)]])
{
    float4 texColor = texture.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = (texColor.rgb + uniforms.screenColor.rgb * texColor.a) - (texColor.rgb * uniforms.screenColor.rgb);
    float4 gl_FragColor = texColor * uniforms.baseColor;

    return gl_FragColor;
}

//// 用于绘制已剪裁内容的片元着色器
fragment float4
FragShaderSrcMask(MaskedRasterizerData in [[stage_in]],
                    texture2d<float> texture0 [[ texture(0) ]],
                    texture2d<float> texture1 [[ texture(1) ]],
                    constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                    sampler smp [[sampler(0)]])
{
    float4 texColor = texture0.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = texColor.rgb + uniforms.screenColor.rgb - (texColor.rgb * uniforms.screenColor.rgb);
    float4 col_formask = texColor * uniforms.baseColor;
    col_formask.rgb = col_formask.rgb  * col_formask.a ;
    float4 clipMask = (1.0 - texture1.sample(smp, in.myPos.xy / in.myPos.w)) * uniforms.channelFlag;
    float maskVal = clipMask.r + clipMask.g + clipMask.b + clipMask.a;
    col_formask = col_formask * maskVal;
    float4 gl_FragColor = col_formask;
    return gl_FragColor;
}

//// 用于反转剪裁的片元着色器
fragment float4
FragShaderSrcMaskInverted(MaskedRasterizerData in [[stage_in]],
                    texture2d<float> texture0 [[ texture(0) ]],
                    texture2d<float> texture1 [[ texture(1) ]],
                    constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                    sampler smp [[sampler(0)]])
{
    float4 texColor = texture0.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = texColor.rgb + uniforms.screenColor.rgb - (texColor.rgb * uniforms.screenColor.rgb);
    float4 col_formask = texColor * uniforms.baseColor;
    col_formask.rgb = col_formask.rgb  * col_formask.a ;
    float4 clipMask = (1.0 - texture1.sample(smp, in.myPos.xy / in.myPos.w)) * uniforms.channelFlag;
    float maskVal = clipMask.r + clipMask.g + clipMask.b + clipMask.a;
    col_formask = col_formask * (1.0 - maskVal);
    float4 gl_FragColor = col_formask;
    return gl_FragColor;
}

//// 用于 PremultipliedAlpha 剪裁的片元着色器
fragment float4
FragShaderSrcMaskPremultipliedAlpha(MaskedRasterizerData in [[stage_in]],
                    texture2d<float> texture0 [[ texture(0) ]],
                    texture2d<float> texture1 [[ texture(1) ]],
                                    constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                                    sampler smp [[sampler(0)]])
{
    float4 texColor = texture0.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = (texColor.rgb + uniforms.screenColor.rgb * texColor.a) - (texColor.rgb * uniforms.screenColor.rgb);
    float4 col_formask = texColor * uniforms.baseColor;
    float4 clipMask = (1.0 - texture1.sample(smp, in.myPos.xy / in.myPos.w)) * uniforms.channelFlag;
    float maskVal = clipMask.r + clipMask.g + clipMask.b + clipMask.a;
    col_formask = col_formask * maskVal;
    float4 gl_FragColor = col_formask;
    return gl_FragColor;
}

//// Normal & Add & Mult 共通（クリッピングされて反転使用の描画用、PremultipliedAlphaの場合）
fragment float4
FragShaderSrcMaskInvertedPremultipliedAlpha(MaskedRasterizerData in [[stage_in]],
                    texture2d<float> texture0 [[ texture(0) ]],
                    texture2d<float> texture1 [[ texture(1) ]],
                    constant CubismShaderUniforms &uniforms  [[ buffer(MetalVertexInputIndexUniforms) ]],
                    sampler smp [[sampler(0)]])
{
    float4 texColor = texture0.sample(smp, in.texCoord);
    texColor.rgb = texColor.rgb * uniforms.multiplyColor.rgb;
    texColor.rgb = (texColor.rgb + uniforms.screenColor.rgb * texColor.a) - (texColor.rgb * uniforms.screenColor.rgb);
    float4 col_formask = texColor * uniforms.baseColor;
    float4 clipMask = (1.0 - texture1.sample(smp, in.myPos.xy / in.myPos.w)) * uniforms.channelFlag;
    float maskVal = clipMask.r + clipMask.g + clipMask.b + clipMask.a;
    col_formask = col_formask * (1.0 - maskVal);
    float4 gl_FragColor = col_formask;
    return gl_FragColor;
}
