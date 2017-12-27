//
//  WBMaintenanceStorageInfoTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/27.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBMaintenanceStorageInfoTableViewCell.h"

@implementation WBMaintenanceStorageInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)startButtonClick:(UIButton *)sender {
    if (self.clickBlock) {
        _clickBlock(sender);
    }
}
@end
