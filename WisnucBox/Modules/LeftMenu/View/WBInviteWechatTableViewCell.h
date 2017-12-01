//
//  WBInviteWechatTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/1.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WBInviteWechatTableViewCell;
typedef void(^resolvedBtnClockBlock)(WBInviteWechatTableViewCell * inviteCell);
typedef void(^rejectedBtnClockBlock)(WBInviteWechatTableViewCell * inviteCell);

@interface WBInviteWechatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stateTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *rejectedButton;

@property (weak, nonatomic) IBOutlet UIButton *resolvedButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (nonatomic) resolvedBtnClockBlock resolvedClickBlock;
@property (nonatomic) rejectedBtnClockBlock rejectedClickBlock;
@end
