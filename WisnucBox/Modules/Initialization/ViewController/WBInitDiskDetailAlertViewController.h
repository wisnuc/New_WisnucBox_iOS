//
//  WBInitDiskDetailAlertViewController.h
//  WisnucBox
//
//  Created by liupeng on 2017/12/18.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBStationManageStorageModel.h"

@interface WBInitDiskDetailAlertViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *interfaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *explainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftIconImageView;
@property (nonatomic,strong) WBStationManageBlocksModel *blocksmodel;
@end
