//
//  WBChatViewNormalTableViewCell.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBChatViewBaseTableViewCell.h"
#import "LHChatTextBubbleView.h"
#import "LHChatImageBubbleView.h"
#import "LHChatAudioBubbleView.h"
#import "LHChatVideoBubbleView.h"
#import "LHChatLocationBubbleView.h"

@interface WBChatViewNormalTableViewCell : WBChatViewBaseTableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activtiy;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;
@end
