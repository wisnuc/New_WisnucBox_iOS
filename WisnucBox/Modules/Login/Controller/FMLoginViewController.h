//
//  FMLoginViewController.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/14.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FABaseVC.h"
@class CloudModelForUser;
@class GlobalModel;

@interface GlobalModel : NSObject
@property(nonatomic,copy) NSString *guid;
@end

@interface CloudModelForUser : NSObject
@property(nonatomic,copy) NSNumber *isAdmin;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *username;
@property(nonatomic,copy) NSString *uuid;
@property(nonatomic,copy) NSNumber *isFirstUser;
@property(nonatomic,copy) NSString *stationId;
@property(nonatomic) GlobalModel *global;
@end

@interface FMLoginViewController : FABaseVC
- (void)weChatCallBackRespCode:(NSString *)code;
@end
