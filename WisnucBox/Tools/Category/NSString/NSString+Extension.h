//
//  NSString+Extension.h
//  Dialysis
//
//  Created by jackygood on 14/12/27.
//  Copyright (c) 2014年 beyondwinet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntriesModel.h"

@interface NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
+ (NSString *)fileSizeWithFileName:(NSString *)fileName;
+ (NSString *)fileSizeWithFLModel:(EntriesModel *)model;
+ (NSString *)URLDecodedString:(NSString *)str;
+ (NSString *)transformedValue:(id)value;
+ (NSString *)getReleaseTime:(long long)releaseTime;
@end
