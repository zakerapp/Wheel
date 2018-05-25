//
//  WHLDefines.h
//  Wheel
//
//  Created by Vernon on 2017/11/22.
//  Copyright © 2017年 ZAKER. All rights reserved.
//

#ifndef WHLDefines_h
#define WHLDefines_h

#ifdef __cplusplus
#define WHL_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define WHL_EXTERN extern __attribute__((visibility("default")))
#endif

#define WHL_INLINE static inline

#endif /* WHLDefines_h */
