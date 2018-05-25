//
//  WHLMaths.h
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHLDefines.h"


/**
 Return random value in [1, upperBounds].
 @param upperBounds max value
 @returns A random integer.
 */
WHL_EXTERN NSInteger WHLRandomInteger(NSInteger upperBounds);


/**
 Return a random number in [min, max]
 @param minVal min value
 @param maxVal max value
 @returns A NSInteger array.
 */
WHL_EXTERN NSInteger *WHLCreateRandomSequence(NSInteger minVal, NSInteger maxVal);



