//
//  WBMaintenanceStorageInfoTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/27.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^startBtnClockBlock)(UIButton * button);

@interface WBMaintenanceStorageInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *diskTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *diskDetailInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic) startBtnClockBlock clickBlock;
@end
