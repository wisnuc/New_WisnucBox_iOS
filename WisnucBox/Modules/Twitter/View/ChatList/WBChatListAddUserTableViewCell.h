//
//  WBChatListAddUserTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBChatListAddUserTableViewCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkBox;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
