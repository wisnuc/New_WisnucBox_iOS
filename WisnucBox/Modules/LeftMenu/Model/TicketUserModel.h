//
//  TicketUserModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface TicketStationModel : NSObject
@property (nonatomic) NSArray *users;
@property (nonatomic,copy) NSString *createdAt;
@property (nonatomic,copy) NSString *ticketId;
@end

@interface TicketUserModel : WBBaseModel
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *avatarUrl;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *createdAt;
@property (nonatomic,copy) NSString *ticketId;
@end
