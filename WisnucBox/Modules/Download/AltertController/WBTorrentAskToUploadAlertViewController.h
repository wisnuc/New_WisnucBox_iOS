//
//  WBTorrentAskToUploadAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBTorrentAskToUploadAlertViewController;
@protocol WBTorrentAskToUploadAlertDelegate <NSObject>

- (void)confirmWithTypeString:(NSString *)typeString isAlways:(BOOL)always;

@end
@interface WBTorrentAskToUploadAlertViewController : UIViewController
@property (nonatomic,weak) id<WBTorrentAskToUploadAlertDelegate> delegate;
@property (nonatomic) NSString *typeString;
@end
