//
//  WBInitDiskTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBInitDiskTableViewCell.h"
@interface WBInitDiskTableViewCell()<BEMCheckBoxDelegate>

@end

@implementation WBInitDiskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.checkBox.boxType = BEMBoxTypeSquare;
    self.checkBox.onAnimationType = BEMAnimationTypeBounce;
    self.checkBox.offAnimationType = BEMAnimationTypeBounce;
    self.checkBox.onFillColor = COR1;
    self.checkBox.onTintColor = COR1;
    self.checkBox.onCheckColor = [UIColor whiteColor];
    self.checkBox.delegate = self;
}

- (void)didTapCheckBox:(BEMCheckBox*)checkBox{
    if (self.cellCheckBoxBlock) {
        _cellCheckBoxBlock(checkBox);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
