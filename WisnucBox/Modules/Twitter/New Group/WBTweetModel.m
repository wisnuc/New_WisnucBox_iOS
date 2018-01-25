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
    return @[@"isSender", @"isRead",@"messageBodytype",@"status",@"width",@"height",@"boxuuid"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WBTweetlistModel class],
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _messageBodytype = MessageBodyType_Image;
    [self.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.metadata) {
            *stop = YES;
            _messageBodytype = MessageBodyType_File;
        }
    }];
    
    if (_messageBodytype == MessageBodyType_Image) {
//        NSInteger x = 3;
//        NSInteger y = 2;
//        if (self.list.count % x == 0) {
//            self.height = IMAGE_MAX_SIZE *((int)floorf(self.list.count/x));
//            self.width = IMAGE_MAX_SIZE *self.list.count + SEPARATE *self.list.count;
//        }else if (self.list.count % y == 0){
//            self.height = IMAGE_MAX_SIZE *((int)floorf(self.list.count/y));
//            self.width = IMAGE_MAX_SIZE *self.list.count + SEPARATE *self.list.count;
//        }
    }
    return YES;
}

@end
