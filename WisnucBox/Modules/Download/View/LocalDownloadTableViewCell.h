//
//  LocalDownloadTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDownloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadedSizeLabel;

@end
