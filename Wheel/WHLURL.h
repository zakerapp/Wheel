//
//  WHLURL.h
//  Wheel
//
//  Created by Steven Mok on 14-8-19.
//  Copyright (c) 2014年 ZAKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (WHLURLAdditions)

- (NSURL *)whl_makeDirectory;
- (BOOL)whl_isFilePath;

@end

@interface NSString (WHLURLAdditions)

- (NSString *)whl_makeDirectory;

@end
