//
//  FMUserEditVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FABaseVC.h"
#import "UserModel.h"

typedef NS_ENUM(NSInteger, UserEditType) {
    UserEdit = 0,
    UserDetail
};

@interface TicketModel : NSObject
@property (nonatomic,copy)NSString *ticketId;
@end

@interface FMUserEditVC : FABaseVC
@property (nonatomic) UserModel *userModel;
@property (nonatomic) UserEditType type;
- (void)weChatCallBackRespCode:(NSString *)code;
@end
