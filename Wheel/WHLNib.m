//
//  WHLNib.m
//  Wheel
//
//  Created by Steven Mok on 16/8/4.
//  Copyright © 2016年 ZAKER. All rights reserved.
//

#import "WHLNib.h"
#import "WHLError.h"

@implementation NSObject (WHLNibAdditions)

+ (instancetype)whl_instanceWithNibName:(NSString *)nibName
{
    if (!nibName) {
        nibName = [self description];
    }

    id object = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] firstObject];

    if (object && [object isKindOfClass:self]) {
        return object;
    } else {
        WHLException(@"Nib first object is not valid.");
        return nil;
    }
}

@end
