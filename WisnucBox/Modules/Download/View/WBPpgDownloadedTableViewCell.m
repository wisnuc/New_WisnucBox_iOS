//
//  WBPpgDownloadedTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBPpgDownloadedTableViewCell.h"

@implementation WBPpgDownloadedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.moreButton setEnlargeEdgeWithTop:7 right:10 bottom:7 left:10];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)moreButtonClick:(UIButton *)sender {
    if (self.clickBlock) {
        @weaky(self);
        _clickBlock(weak_self);
    }
}

@end
