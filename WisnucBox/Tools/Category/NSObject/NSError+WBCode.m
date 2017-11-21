//
//  NSError+WBCode.m
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "NSError+WBCode.h"
#import <objc/runtime.h>

@implementation NSError (WBCode)
const char kErrorWBCode;

- (void)setWbCode:(NSInteger)wbCode {
    objc_setAssociatedObject(self, &kErrorWBCode, [NSNumber numberWithInteger:wbCode], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)wbCode {
    NSNumber * code = objc_getAssociatedObject(self, &kErrorWBCode);
    if(!code) return -1;
    return [code integerValue];
}

@end
