//
//  WHLCache.m
//  Wheel
//
//  Created by Steven Mok on 13-12-13.
//  Copyright (c) 2013年 ZAKER. All rights reserved.
//

#import "WHLCache.h"

@implementation WHLCache

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [self removeAllObjects];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
