//
//  WBSettingSelectPpgAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SettingSelectPpgAlertViewDelegate <NSObject>

- (void)confirmWithTypeString:(NSString *)typeString;

@end
@interface WBSettingSelectPpgAlertViewController : UIViewController
@property (nonatomic,weak) id<SettingSelectPpgAlertViewDelegate> delegate;
@property (nonatomic) NSString *typeString;
@end
