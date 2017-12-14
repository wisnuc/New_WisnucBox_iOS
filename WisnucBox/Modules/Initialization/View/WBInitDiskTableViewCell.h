//
//  WBInitDiskTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBInitDiskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet BEMCheckBox *checkBox;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftIconImageView;

@end
