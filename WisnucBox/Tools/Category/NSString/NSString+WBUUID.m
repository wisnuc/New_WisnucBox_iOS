//
//  NSString+WBUUID.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "NSString+WBUUID.h"

@implementation NSString (WBUUID)

+ (NSString *)WB_UUID{
    CFUUIDRef   uuid_ref        = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
