//
//  WBChatListAddUserTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatListAddUserTableViewCell.h"

@implementation WBChatListAddUserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.width/2;
    self.checkBox.boxType = BEMBoxTypeCircle;
    self.checkBox.onAnimationType = BEMAnimationTypeBounce;
    self.checkBox.offAnimationType = BEMAnimationTypeBounce;
    self.checkBox.onFillColor = COR1;
    self.checkBox.onTintColor = COR1;
    self.checkBox.onCheckColor = [UIColor whiteColor];
    self.checkBox.userInteractionEnabled = NO;
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
