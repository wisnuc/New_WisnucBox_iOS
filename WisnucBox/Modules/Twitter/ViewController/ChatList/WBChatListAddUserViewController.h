//
//  WBChatListAddUserViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "FABaseVC.h"
#import "WBBoxesModel.h"
@protocol ChatListAddUserEndDelegate <NSObject>
- (void)endAddUser;
@end

@interface WBChatListAddUserViewController : FABaseVC
@property (nonatomic,weak)id<ChatListAddUserEndDelegate> endDelegate;
@property (nonatomic)WBUserAddressBookType type;
@property (nonatomic)WBBoxesModel *boxModel;
@end
