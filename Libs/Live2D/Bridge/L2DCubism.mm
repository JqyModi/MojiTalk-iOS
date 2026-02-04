//
//  L2DCubism.m
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//

#import <Foundation/Foundation.h>
#import "CubismFramework.hpp"
#import "L2DCubism.h"
#import "Rendering/Metal/CubismRenderingInstanceSingleton_Metal.h"

using namespace Csm;

/// Cubism allocator.
class Allocator: public ICubismAllocator {
    void* Allocate(const csmSizeType size) {
        return malloc(size);
    }
    
    void Deallocate(void* memory) {
        free(memory);
    }
    
    void* AllocateAligned(const csmSizeType size, const csmUint32 alignment) {
        size_t offset, shift, alignedAddress;
        void* allocation;
        void** preamble;

        offset = alignment - 1 + sizeof(void*);

        allocation = Allocate(size + static_cast<csmUint32>(offset));

        alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void*);

        shift = alignedAddress % alignment;

        if (shift) {
            alignedAddress += (alignment - shift);
        }

        preamble = reinterpret_cast<void**>(alignedAddress);
        preamble[-1] = allocation;

        return reinterpret_cast<void*>(alignedAddress);
    }
    
    void DeallocateAligned(void* alignedMemory) {
        void** preamble;

        preamble = static_cast<void**>(alignedMemory);

        Deallocate(preamble[-1]);
    }
};

static Allocator allocator;

@implementation L2DCubism

+ (void)setup {
    CubismFramework::StartUp(&allocator, NULL);
    CubismFramework::Initialize();
    // 在 Cubism 渲染框架中注册 Metal 设备
    CubismRenderingInstanceSingleton_Metal *single = [CubismRenderingInstanceSingleton_Metal sharedManager];
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();  // 获取系统默认 Metal 设备
    [single setMTLDevice:device];  // 将 Metal 设备注册到 Cubism 渲染实例中
}

+ (void)dispose {
    CubismFramework::Dispose();
}

+ (NSString *)live2DVersion {
    unsigned int version = Live2D::Cubism::Core::csmGetVersion();
    unsigned int major = (version >> 24) & 0xff;
    unsigned int minor = (version >> 16) & 0xff;
    unsigned int patch = version & 0xffff;

    return [NSString stringWithFormat:@"v%1$d.%2$d.%3$d", major, minor, patch];
}

@end
