//
//  WBSettingUpgradeSelectViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SettingUpgradeSelectAlertViewDelegate <NSObject>

- (void)confirmUpgradWithTypeString:(NSString *)typeString;

@end
@interface WBSettingUpgradeSelectViewController : UIViewController
@property (nonatomic,strong) NSString *typeString;
@property (nonatomic,weak) id<SettingUpgradeSelectAlertViewDelegate> delegate;
@end
