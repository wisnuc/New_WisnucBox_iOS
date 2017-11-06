//
//  WBAsset.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBAsset.h"

@implementation WBAsset

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"fmlong" : @"long",
             @"fmhash": @"hash"
             };
}

@end
