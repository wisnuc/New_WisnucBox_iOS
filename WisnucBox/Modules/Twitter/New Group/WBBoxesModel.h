//
//  WBBoxesModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"
//uuid: 'a96241c5-bfe2-458f-90a0-46ccd1c2fa9a',
//name: 'hello',
//owner: 'ocMvos6NjeKLIBqg5Mr9QjxrP1FA',
//users: [],
//ctime: 1515996040812,
//mtime: 1515996040812


@interface WBBoxesTweetModel : NSObject
@property(nonatomic,copy)NSString *comment;
@property(nonatomic,copy)NSString *createdAt;
@property(nonatomic,copy)NSString *updatedAt;
@property(nonatomic,copy)NSNumber *ctime;
@property(nonatomic,copy)NSNumber *index;
@property(nonatomic,copy)NSString *tweeter;
@property(nonatomic,copy)NSString *type;
@property (nonatomic)NSArray *list;
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
@property(nonatomic)WBBoxesTweetModel *tweet;
@end
