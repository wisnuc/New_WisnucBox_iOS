//
//  WBBoxesModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBBoxesModel.h"
@implementation WBBoxesUsersModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"userId" : @"id",
             };
}
@end

@implementation WBBoxesModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [WBBoxesUsersModel class]
             };
}
@end
