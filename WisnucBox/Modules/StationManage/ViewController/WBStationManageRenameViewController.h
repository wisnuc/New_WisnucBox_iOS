//
//  WBStationManageRenameViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FABaseVC.h"

@interface WBStationManageRenameViewController : FABaseVC
@property (weak, nonatomic) IBOutlet UITextField *renameTextField;
@property (nonatomic,strong) NSString *stationName;
@end
