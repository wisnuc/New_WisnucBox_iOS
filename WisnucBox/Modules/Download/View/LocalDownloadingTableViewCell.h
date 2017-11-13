//
//  LocalDownloadingTableViewCell.h
//  GSDownloadDemo
//
//  Created by wisnuc-imac on 2017/11/9.
//  Copyright © 2017年 wisnuc-imac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDownloadingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end
