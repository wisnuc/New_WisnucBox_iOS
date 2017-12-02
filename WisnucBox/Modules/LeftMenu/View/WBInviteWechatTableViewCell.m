//
//  WBInviteWechatTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/1.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInviteWechatTableViewCell.h"

@implementation WBInviteWechatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.rejectedButton setHidden:YES];
    [self.resolvedButton setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)resolvedButtonClick:(UIButton *)sender {
    if (self.resolvedClickBlock) {
        _resolvedClickBlock(self);
    }
}

- (IBAction)rejectedButtonClick:(UIButton *)sender {
    if (self.rejectedClickBlock) {
//        @weaky(self);
        _rejectedClickBlock(self);
    }
}

@end
