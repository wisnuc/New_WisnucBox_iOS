//
//  WBTorrentDownloadedTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WBTorrentDownloadedTableViewCell;
typedef void(^moreButtonClockBlock)(WBTorrentDownloadedTableViewCell * cell);
@interface WBTorrentDownloadedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic) moreButtonClockBlock clickBlock;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

@end
