//
//  WBStationManageRenameViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FABaseVC.h"

@class ReNameDelegate;
@protocol ReNameDelegate <NSObject>

-(void)reNameComplete;

@end

@interface WBStationManageRenameViewController : FABaseVC
@property (weak, nonatomic) IBOutlet UITextField *renameTextField;
@property (nonatomic,weak) id<ReNameDelegate> delegate;
@property (nonatomic,strong) NSString *stationName;
@property (nonatomic,strong) NSString *boxuuid;
@property (nonatomic) WBRenameVCType vcType;
@end
