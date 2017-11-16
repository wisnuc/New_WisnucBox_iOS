//
//  LocalDownloadingTableViewCell.m
//  GSDownloadDemo
//
//  Created by wisnuc-imac on 2017/11/9.
//  Copyright © 2017年 wisnuc-imac. All rights reserved.
//

#import "LocalDownloadingTableViewCell.h"

@implementation LocalDownloadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlelongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.contentView addGestureRecognizer:longPress];
    [self.cancelButton setEnlargeEdgeWithTop:6 right:12 bottom:6 left:6];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.layerView.layer.cornerRadius = 20;
}

- (IBAction)cancelBtn:(UIButton *)sender {
    if (self.clickBlock) {
        @weaky(self);
        _clickBlock(weak_self);
    }
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
