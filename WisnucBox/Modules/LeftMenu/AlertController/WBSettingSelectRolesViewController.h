//
//  WBSettingSelectRolesViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/25.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingSelectRolesAlertViewDelegate <NSObject>

- (void)confirmWithTypeString:(NSString *)typeString;

@end

@interface WBSettingSelectRolesViewController : UIViewController
@property(nonatomic)NSString *typeString;
@property (nonatomic,weak) id<SettingSelectRolesAlertViewDelegate> delegate;
@end
