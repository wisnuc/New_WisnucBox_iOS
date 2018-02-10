//
//  WBBoxesModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface WBBoxesStationModel : NSObject
//LANIP = "10.10.9.214";
//id = "f448eca8-b079-42dc-8ceb-b235de864c1d";
//isOnline = 1;
//name = "J-214\U578b\U6d4b\U8bd5\U673a";
//status = 1;
@property(nonatomic,copy)NSString *LANIP;
@property(nonatomic,copy)NSNumber *isOnline;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSNumber *status;
@property(nonatomic,copy)NSString *stationId;
@end

@interface WBBoxesTweetModel : NSObject
@property(nonatomic,copy)NSString *comment;
@property(nonatomic,copy)NSString *createdAt;
@property(nonatomic,copy)NSString *updatedAt;
@property(nonatomic,copy)NSNumber *ctime;
@property(nonatomic,copy)NSNumber *index;
@property(nonatomic,copy)NSString *tweeter;
@property(nonatomic,copy)NSString *type;
@property (nonatomic)NSArray *list;
@property(nonatomic,copy)NSString *uuid;
@end

@interface WBBoxesUsersModel : NSObject
@property(nonatomic,copy)NSString *avatarUrl;
@property(nonatomic,copy)NSString *nickName;
@property(nonatomic,copy)NSNumber *status;
@property(nonatomic,copy)NSString *userId;
@end

@interface WBBoxesModel : WBBaseModel
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *owner;
@property(nonatomic)NSArray *users;
@property(nonatomic,assign)long long ctime;
@property(nonatomic,assign)long long mtime;
@property(nonatomic)WBTweetModel *tweet;
@property(nonatomic)WBBoxesStationModel *station;
@end
