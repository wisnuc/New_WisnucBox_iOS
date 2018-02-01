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

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
 
    return YES;
}

@end


@implementation WBTweetModel
// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[@"isSender", @"isRead",@"messageBodytype",@"status",@"width",@"height",@"boxuuid",@"localImageArray"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [WBTweetlistModel class],
             };
}

- (void)setLocalImageArray:(NSArray *)localImageArray{
    _localImageArray = localImageArray;
    if (self.isSender) {
        [self setImageWidthHeightWithX:3 Y:2 Array:self.localImageArray];
    }
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    if ([self.tweeter.tweeterId isEqualToString:WB_UserService.currentUser.guid]) {
        self.isSender = YES;
    }
    _messageBodytype = MessageBodyType_Image;
    if (self.isSender) {
        [self setImageWidthHeightWithX:3 Y:2 Array:self.localImageArray];
        [self setImageWidthHeightWithX:3 Y:2 Array:self.list];
        return YES;
    }
    [self.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.metadata) {
            *stop = YES;
            _messageBodytype = MessageBodyType_File;
        }
    }];
    
    if (_messageBodytype == MessageBodyType_Image) {
        [self setImageWidthHeightWithX:3 Y:2 Array:self.list];
    }
    
    return YES;
}

- (void)setImageWidthHeightWithX:(NSInteger)x Y:(NSInteger)y Array:(NSArray *)array{
//    NSInteger x = 3;
//    NSInteger y = 2;
    if (array.count >=5) {
        self.height = THREE_IMAGE_SIZE *2;
        self.width = THREE_IMAGE_SIZE *3 + SEPARATE *3;
    }else
        if (array.count == 1) {
            self.height = MAX_SIZE;
            self.width = MAX_SIZE;
        }else if (array.count % x == 0) {
            self.height = THREE_IMAGE_SIZE *((int)floorf(array.count/x));
            self.width = THREE_IMAGE_SIZE *3 + SEPARATE *array.count;
        }else if (array.count % y == 0){
            if (array.count == 4) {
                self.height = THREE_IMAGE_SIZE *((int)floorf(array.count/y));
                self.width = THREE_IMAGE_SIZE *2 + SEPARATE *array.count;
            }else{
                self.height = MAX_SIZE *((int)floorf(array.count/y));
                self.width = MAX_SIZE *2 + SEPARATE *array.count;
            }
        }
    
}

@end
