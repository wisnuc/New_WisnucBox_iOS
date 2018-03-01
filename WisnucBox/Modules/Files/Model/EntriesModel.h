//
//  EntriesModel.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/21.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntriesModel : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *photoHash;
@property (nonatomic) NSNumber *magic;
@property (nonatomic) long long mtime;
@property (nonatomic) long long size;
@property (nonatomic) NSString *driveUUID;
@property (nonatomic) NSString *parentUUID;
@end
