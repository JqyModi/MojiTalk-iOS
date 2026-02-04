/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DPal.h"
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import <stdarg.h>
#import <sys/stat.h>
#import <iostream>
#import <fstream>
#import "L2DDefine.h"

using std::endl;
using namespace Csm;
using namespace std;
using namespace L2DDefine;

// 从文件路径加载文件为字节数组
csmByte* L2DPal::LoadFileAsBytes(const string filePath, csmSizeInt* outSize)
{
    NSURL *url = [NSURL fileURLWithPath: [NSString stringWithUTF8String:filePath.c_str()]];

    NSData* data = [NSData dataWithContentsOfURL: url];

    // 文件加载失败
    if (data == nil)
    {
        PrintLogLn("File load failed : %s", filePath.c_str());
        return NULL;
    }
    // 文件大小为0
    else if (data.length == 0)
    {
        PrintLogLn("File is loaded but file size is zero : %s", filePath.c_str());
        return NULL;
    }

    // 读取文件内容到字节数组中
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);

    *outSize = static_cast<Csm::csmSizeInt>(len); // 返回文件大小
    return static_cast<Csm::csmByte*>(byteData);
}

// 释放字节数组内存
void L2DPal::ReleaseBytes(csmByte* byteData)
{
    free(byteData);
}

// 打印日志，支持可变参数
void L2DPal::PrintLogLn(const csmChar* format, ...)
{
    va_list args;
    Csm::csmChar buf[256];
    va_start(args, format);
    vsnprintf(buf, sizeof(buf), format, args); // 格式化日志字符串
    NSLog(@"%@", [NSString stringWithCString:buf encoding:NSUTF8StringEncoding]); // 输出到控制台
    va_end(args);
}

// 打印消息，调用 PrintLogLn 方法
void L2DPal::PrintMessageLn(const csmChar* message)
{
    PrintLogLn("%s", message); // 格式化并输出消息
}

