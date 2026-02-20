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
#import "Bridge/OpenMTKView.h"
#import "Bridge/OpenL2DConfigurationModel.h"

FOUNDATION_EXPORT double OpenLive2DVersionNumber;
FOUNDATION_EXPORT const unsigned char OpenLive2DVersionString[];

