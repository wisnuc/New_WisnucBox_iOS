//
//  WBTorrentDownloadingTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentDownloadingTableViewCell.h"

@implementation WBTorrentDownloadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.moreButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:10];
    // Initialization code
    
}
- (IBAction)moreButtonClick:(UIButton *)sender {
    if (self.clickBlock) {
        @weaky(self);
        _clickBlock(weak_self);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
