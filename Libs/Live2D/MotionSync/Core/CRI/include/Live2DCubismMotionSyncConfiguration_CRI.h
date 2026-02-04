/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Proprietary Software license
 * that can be found at https://www.live2d.com/eula/live2d-proprietary-software-license-agreement_en.html.
 */

#ifndef LIVE2D_CUBISM_MOTIONSYNC_ENGINE_CONFIG_CRI_INCLUDED
#define LIVE2D_CUBISM_MOTIONSYNC_ENGINE_CONFIG_CRI_INCLUDED

 /* ---------------------- *
  * ALLOCATOR DECRALATIONS *
  * ---------------------- */

/** Decralation of allocator. */
typedef void* (*csmMotionSync_AllocFunc)(unsigned int size);

/** Decralation of aligned allocator. */
typedef void* (*csmMotionSync_AlignedAllocFunc)(unsigned int size, unsigned int align);

/** Decralation of deallocator. */
typedef void (*csmMotionSync_DeallocFunc)(void* ptr);

/** Decralation of aligned deallocator. */
typedef void (*csmMotionSync_AlignedDeallocFunc)(void* ptr);


/**
 * Engine configuration for CRI.
 */
typedef struct
{
    /** Pointer to Allocator. */
    csmMotionSync_AllocFunc Allocator;
    /** Pointer to Deallocator. */
    csmMotionSync_DeallocFunc Deallocator;
} csmMotionSync_EngineConfig_CRI;

/**
 * Context cofiguration for CRI.
 */
typedef struct
{
    /** Audio sample rate. */
    int SampleRate;

    /** Audio bit depth. */
    int BitDepth;
} csmMotionSync_ContextConfig_CRI;

/**
 * Analysis cofiguration for CRI.
 */
typedef struct
{
    /** Blending ratio for vieseme. */
    float BlendRatio;

    /** Smoothing value. */
    int Smoothing;

    /** Audio level effect ratio. */
    float AudioLevelEffectRatio;
} csmMotionSync_AnalysisConfig_CRI;

#endif  // LIVE2D_CUBISM_MOTIONSYNC_ENGINE_CONFIG_CRI_INCLUDED
