//
//  L2DCubism.h
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//

#import <Foundation/Foundation.h>

/// Live2D Cubism framework ObjC wrapper.
@interface L2DCubism: NSObject

/// Init cubism framework.
+ (void)setup;

/// Dispose cubism framework.
+ (void)dispose;

/// Live 2d framework version
+ (NSString *)live2DVersion;

@end

