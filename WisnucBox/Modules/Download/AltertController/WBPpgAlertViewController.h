//
//  WBPpgAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PpgAlertViewDelegate <NSObject>

- (void)Ppgdownload:(NSString *)url;

@end

@interface WBPpgAlertViewController : UIViewController
@property (nonatomic,weak)id<PpgAlertViewDelegate>delegate;
@end
