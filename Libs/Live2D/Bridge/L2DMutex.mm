/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import "L2DMutex.h"

L2DMutex::L2DMutex()
{
    pthread_mutex_init(&_mutex, NULL);
}

L2DMutex::~L2DMutex()
{
    pthread_mutex_destroy(&_mutex);
}

void L2DMutex::Lock()
{
    pthread_mutex_lock(&_mutex);
}

void L2DMutex::Unlock()
{
    pthread_mutex_unlock(&_mutex);
}
