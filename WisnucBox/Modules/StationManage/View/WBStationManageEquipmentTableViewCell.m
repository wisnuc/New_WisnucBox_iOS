//
//  WBStationManageEquipmentTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageEquipmentTableViewCell.h"

@implementation WBStationManageEquipmentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.editButton setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
