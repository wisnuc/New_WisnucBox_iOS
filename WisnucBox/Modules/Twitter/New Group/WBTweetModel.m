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
// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[@"isSender", @"isRead",@"messageBodytype",@"status",@"width",@"height"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WBTweetlistModel class],
             };
}

// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    
//    dic[@"timestamp"] = @(n.timeIntervalSince1970);
    return YES;
}

@end
