//
//  EntriesModel.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/21.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "EntriesModel.h"

@implementation EntriesModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"photoHash": @"hash"
             };
}
+ (NSArray *)modelPropertyBlacklist {
    return @[@"driveUUID", @"parentUUID"];
}

- (id)copyWithZone:(NSZone *)zone {
    EntriesModel *newClass = [[EntriesModel alloc]init];
    newClass.name = self.name;
    newClass.type = self.type;
    newClass.uuid = self.uuid;
    newClass.photoHash = self.photoHash;
    newClass.magic = self.magic;
    newClass.mtime = self.mtime;
    newClass.size = self.size;
    return newClass;
}
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    EntriesModel *newClass = [[EntriesModel alloc]init];
    newClass.name = self.name;
    newClass.type = self.type;
    newClass.uuid = self.uuid;
    newClass.photoHash = self.photoHash;
    newClass.magic = self.magic;
    newClass.mtime = self.mtime;
    newClass.size = self.size;
    return newClass;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    return YES;
}

@end
