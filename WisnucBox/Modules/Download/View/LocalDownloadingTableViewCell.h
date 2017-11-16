//
//  LocalDownloadingTableViewCell.h
//  GSDownloadDemo
//
//  Created by wisnuc-imac on 2017/11/9.
//  Copyright © 2017年 wisnuc-imac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalDownloadTableViewCell.h"

@class LocalDownloadingTableViewCell;

typedef void(^cancelBtnClockBlock)(LocalDownloadingTableViewCell * cell);
typedef void(^longPressDownloadingBlock)(LocalDownloadingTableViewCell * cell);

@interface LocalDownloadingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *f_ImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *layerView;

@property (nonatomic) longPressDownloadingBlock longpressBlock;
@property (nonatomic) cancelBtnClockBlock clickBlock;
@property (nonatomic) LocalFliesCellStatus status;

@end
