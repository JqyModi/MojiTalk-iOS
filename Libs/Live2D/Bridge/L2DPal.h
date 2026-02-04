/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#ifndef L2DPal_h
#define L2DPal_h

#import <string>
#import "CubismFramework.hpp"

/**
 * @brief Cubism 平台抽象层，抽象平台相关的功能。
 *
 * 组织与平台相关的功能，例如文件读取和Log。
 *
 */
class L2DPal
{
public:
    /**
     * @brief 将文件读取为字节数据
     *
     * 将文件读取为字节数据
     *
     * @param[in]   filePath    要读取的文件的路径
     * @param[out]  outSize     文件大小
     * @return                  字节数据
     */
    static Csm::csmByte* LoadFileAsBytes(const std::string filePath, Csm::csmSizeInt* outSize);


    /**
     * @brief 释放字节数据
     *
     * 释放字节数据
     *
     * @param[in]   byteData    想要释放的字节数据
     */
    static void ReleaseBytes(Csm::csmByte* byteData);

    /**
     * @brief 输出日志并在末尾添加新行
     *
     * 输出日志并在末尾添加新行
     *
     * @param[in] format 格式化字符串
     * @param[in] ... (可变参数) 字符串
     *
     */
    static void PrintLogLn(const Csm::csmChar* format, ...);

    /**
     * @brief 输出消息并在末尾添加换行符
     *
     * 输出消息并在末尾添加新行
     *
     * @param[in]   message  消息字符串
     *
     */
    static void PrintMessageLn(const Csm::csmChar* message);
};

#endif /* L2DPal_h */



