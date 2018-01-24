//
//  WBTweetModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBTweetModel.h"
@implementation WBTweetlistModel

@end

@implementation WBTweetTweeterModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"tweeterId" : @"id",
             };
}
@end

@implementation WBTweetModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WBTweetlistModel class],
             };
}
@end
