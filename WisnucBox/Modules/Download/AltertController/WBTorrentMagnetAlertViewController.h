//
//  WBTorrentMagnetAlertViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TorrentMagnetAlertViewDelegate <NSObject>

- (void)magnetDownload:(NSString *)magnetUrl;

@end

@interface WBTorrentMagnetAlertViewController : UIViewController
@property (nonatomic,weak)id<TorrentMagnetAlertViewDelegate>delegate;
@end
