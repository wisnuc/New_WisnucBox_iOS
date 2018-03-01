//
//  WBTweetModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBTweetModel.h"
@implementation WBTweetlocalImageModel
+ (NSArray *)modelPropertyBlacklist {
    return @[@"localImage", @"asset"];
}

- (id)copyWithZone:(NSZone *)zone {
    WBTweetlocalImageModel *newClass = [[WBTweetlocalImageModel alloc]init];
    newClass.asset = self.asset;
    newClass.localImage = self.localImage;
    return newClass;
}
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    WBTweetlocalImageModel *newClass = [[WBTweetlocalImageModel alloc]init];
    newClass.asset = self.asset;
    newClass.localImage = self.localImage;
    return newClass;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.asset forKey:@"asset"];
    [aCoder encodeObject:self.localImage forKey:@"localImage"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.asset = [aDecoder decodeObjectForKey:@"asset"];
        self.localImage = [aDecoder decodeObjectForKey:@"localImage"];
    }
    return self;
}

@end

@implementation WBTweetlistModel
+ (NSArray *)modelPropertyBlacklist {
    return @[@"localImage", @"asset"];
}

- (id)copyWithZone:(NSZone *)zone {
    WBTweetlistModel *newClass = [[WBTweetlistModel alloc]init];
    newClass.filename = self.filename;
    newClass.sha256 = self.sha256;
    newClass.metadata = self.metadata;
    newClass.size = self.size;
    return newClass;
}
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    WBTweetlistModel *newClass = [[WBTweetlistModel alloc]init];
    newClass.filename = self.filename;
    newClass.sha256 = self.sha256;
    newClass.metadata = self.metadata;
    newClass.size = self.size;
    return newClass;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.filename forKey:@"filename"];
    [aCoder encodeObject:self.sha256 forKey:@"sha256"];
    [aCoder encodeObject:self.metadata forKey:@"metadata"];
    [aCoder encodeObject:self.size forKey:@"size"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.filename = [aDecoder decodeObjectForKey:@"filename"];
        self.sha256 = [aDecoder decodeObjectForKey:@"sha256"];
        self.metadata = [aDecoder decodeObjectForKey:@"metadata"];
        self.size = [aDecoder decodeObjectForKey:@"size"];
    }
    return self;
}
@end


@implementation WBTweetTweeterModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.tweeterId forKey:@"tweeterId"];
    [aCoder encodeObject:self.wx forKey:@"wx"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {        
        self.tweeterId = [aDecoder decodeObjectForKey:@"tweeterId"];
        self.wx = [aDecoder decodeObjectForKey:@"wx"];
    }
    return self;
}

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
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.height forKey:@"height"];
    [aCoder encodeObject:self.boxuuid forKey:@"boxuuid"];
    [aCoder encodeInteger:self.messageBodytype forKey:@"messageBodytype"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.owner forKey:@"owner"];
    [aCoder encodeObject:self.comment forKey:@"comment"];
    [aCoder encodeInt64:self.ctime forKey:@"ctime"];
    [aCoder encodeInteger:self.index forKey:@"index"];
    [aCoder encodeObject:self.list forKey:@"list"];
    [aCoder encodeObject:self.tweeter forKey:@"tweeter"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.localImageArray forKey:@"localImageArray"];
    [aCoder encodeBool:self.isSender forKey:@"isSender"];
    [aCoder encodeBool:self.isRead forKey:@"isRead"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.height = [aDecoder decodeFloatForKey:@"height"];
        self.boxuuid = [aDecoder decodeObjectForKey:@"boxuuid"];
        self.messageBodytype = (MessageBodyType)[aDecoder decodeIntegerForKey:@"messageBodytype"];
        self.status = (MessageDeliveryState)[aDecoder decodeIntegerForKey:@"status"];
        self.owner = [aDecoder decodeObjectForKey:@"owner"];
        self.comment = [aDecoder decodeObjectForKey:@"comment"];
        self.ctime = [aDecoder decodeInt64ForKey:@"ctime"];
        self.index = [aDecoder decodeIntegerForKey:@"index"];
        self.list = [aDecoder decodeObjectForKey:@"list"];
        self.tweeter = [aDecoder decodeObjectForKey:@"tweeter"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.localImageArray = [aDecoder decodeObjectForKey:@"localImageArray"];
        self.isSender = [aDecoder decodeBoolForKey:@"isSender"];
        self.isRead = [aDecoder decodeBoolForKey:@"isRead"];
    }
    return self;
}
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
    if ([dic[@"tweeter"] isKindOfClass:[NSString class]]) {
//        NSLog(@"%@",self.tweeter);
        self.tweeter = [WBTweetTweeterModel new];
        self.tweeter.tweeterId = dic[@"tweeter"];
    }
    if ([self.tweeter.tweeterId isEqualToString:WB_UserService.currentUser.guid]) {
        self.isSender = YES;
    }
    _messageBodytype = MessageBodyType_Image;
 
    [self.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.metadata) {
            _messageBodytype = MessageBodyType_File;
            *stop = YES;
        }
    }];
    
    
    if (self.isSender && _messageBodytype == MessageBodyType_Image) {
        [self setImageWidthHeightWithX:3 Y:2 Array:self.localImageArray];
        [self setImageWidthHeightWithX:3 Y:2 Array:self.list];
        return YES;
    }
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
