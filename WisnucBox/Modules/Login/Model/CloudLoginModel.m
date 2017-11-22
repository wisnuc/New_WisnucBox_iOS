//
//  CloudLoginModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CloudLoginModel.h"


@implementation WBCloadLoginUserModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userId" : @"id",
             };
}

@end

@implementation WBCloadLoginDataModel
//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    return @{@"user" : [WBCloadLoginUserModel class],
//             };
//}
@end

@implementation CloudLoginModel
//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    return @{@"data" : [WBCloadLoginDataModel class],
//             };
//}


@end
