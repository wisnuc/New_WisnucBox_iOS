//
//  CloudLoginModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"
@class WBCloadLoginDataModel;
@class WBCloadLoginUserModel;

@interface WBCloadLoginUserModel : NSObject
@property (nonatomic,copy)NSString *avatarUrl;
@property (nonatomic,copy)NSString *userId;
@property (nonatomic,copy)NSString *nickName;
@end

@interface WBCloadLoginDataModel : NSObject
@property (nonatomic,copy)NSString *token;
@property (nonatomic)WBCloadLoginUserModel *user;
@end

@interface CloudLoginModel : WBBaseModel
@property(nonatomic)WBCloadLoginDataModel *data;
@property(nonatomic)NSString* url;

@end
