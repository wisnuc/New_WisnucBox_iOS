//
//  WBPpgDownloadingTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WBPpgDownloadingTableViewCell;
typedef void(^moreBtnClockBlock)(WBPpgDownloadingTableViewCell * cell);

@interface WBPpgDownloadingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic) moreBtnClockBlock clickBlock;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@end
