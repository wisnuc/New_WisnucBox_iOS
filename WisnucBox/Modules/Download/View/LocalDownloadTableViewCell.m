//
//  LocalDownloadTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "LocalDownloadTableViewCell.h"

@implementation LocalDownloadTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlelongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.contentView addGestureRecognizer:longPress];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.layerView.layer.cornerRadius = 20;
}
- (void)handlelongPress:(id)sender {
    if (self.longpressBlock) {
        @weaky(self);
        _longpressBlock(weak_self);
    }
    
}

- (void)setStatus:(LocalFliesCellStatus)status{
    _status = status;
    self.layerView.hidden = _status ? NO: YES;
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
