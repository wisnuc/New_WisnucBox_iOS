//
//  WBUpgradeCheckViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WBUpgradeCheckAlertDelegate <NSObject>
- (void)confirmWithIsIgnore:(BOOL)ignore;
@end
@interface WBUpgradeCheckViewController : UIViewController
@property (nonatomic,weak) id<WBUpgradeCheckAlertDelegate> delegate;
@end
