//
//  WHLMaths.m
//  Wheel
//
//  Created by Steven Mok on 13-10-10.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLAccessibility.h"
#import "WHLMaths.h"

NSInteger WHLRandomInteger(NSInteger upperBounds)
{
    return arc4random() % upperBounds + 1;
}

NSInteger * WHLCreateRandomSequence(NSInteger minVal, NSInteger maxVal)
{
    NSInteger x = 0, tmp = 0;

    if (minVal > maxVal) {
        tmp = minVal;
        minVal = maxVal;
        maxVal = tmp;
    }

    NSInteger arrayLength = maxVal - minVal + 1;
    NSInteger *array = malloc(arrayLength * sizeof(NSInteger));

    for (NSInteger i = minVal; i <= maxVal; i++) {
        array[i - minVal] = i;
    }

    for (NSInteger i = arrayLength - 1; i > 0; i--) {
        x = arc4random_uniform((u_int32_t)i + 1);
        tmp = array[i];
        array[i] = array[x];
        array[x] = tmp;
    }

    return array;
}
