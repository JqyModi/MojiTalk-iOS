#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Bridge/L2DCubism.h"
#import "Bridge/MOJiMTKView.h"
#import "Bridge/MOJiL2DConfigurationModel.h"

FOUNDATION_EXPORT double MojiLive2DVersionNumber;
FOUNDATION_EXPORT const unsigned char MojiLive2DVersionString[];

