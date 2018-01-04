//
//  WBStationManageTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageTableViewCell.h"

@implementation WBStationManageTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.normalLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (UILabel *)normalLabel{
    if (!_normalLabel) {
        _normalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 4, self.contentView.bounds.size.width, 18)];
        _normalLabel.textColor = [UIColor darkTextColor];
        _normalLabel.font = [UIFont systemFontOfSize:16];
        _normalLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _normalLabel;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.normalLabel.frame) + 8, self.contentView.bounds.size.width, 13)];
        _detailLabel.textColor = [UIColor lightGrayColor];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
