//
//  LocalDownloadTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    LocalFliesCellStatusNormal = 0,
    LocalFliesCellStatusCanChoose,
} LocalFliesCellStatus;

@class LocalDownloadTableViewCell;

typedef void(^longPressBlock)(LocalDownloadTableViewCell * cell);

@interface LocalDownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *f_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *layerView;
@property (nonatomic) longPressBlock longpressBlock;
@property (nonatomic) LocalFliesCellStatus status;
@end
