//
//  WBSettingSelectBTAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SettingSelectBTAlertViewDelegate <NSObject>

- (void)confirmWithTypeString:(NSString *)typeString;

@end
@interface WBSettingSelectBTAlertViewController : UIViewController
@property (nonatomic,weak) id<SettingSelectBTAlertViewDelegate> delegate;
@property (nonatomic) NSString *typeString;
@end
