//
//  WBPpgAskToUploadAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBPpgAskToUploadAlertViewController;
@protocol WBPpgAskToUploadAlertDelegate <NSObject>

- (void)confirmWithTypeString:(NSString *)typeString isAlways:(BOOL)always;

@end
@interface WBPpgAskToUploadAlertViewController : UIViewController
@property (nonatomic,weak) id<WBPpgAskToUploadAlertDelegate> delegate;
@property (nonatomic) NSString *typeString;
@end
