//
//  TicketUserModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface TicketUserModel : WBBaseModel
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *avatarUrl;
//{
//    "userId": "6e6c0c4a-967a-489a-82a2-c6eb6fe9d991",
//    "type": "reject",
//    "nickName": "刘华",
//    "avatarUrl": "https://wx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJBsJR1DhjgRbUKk9adPdl8TfmLj2roOlNQc0alnAySqD56HCeBd7PU5TNBxlfAqqX4ficialTRl9LA/0"
//}
@end
