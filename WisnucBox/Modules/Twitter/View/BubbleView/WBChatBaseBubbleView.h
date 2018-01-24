//
//  WBChatBaseBubbleView.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBTweetModel.h"
#import "UIResponder+Router.h"

@interface WBChatBaseBubbleView : UIView
@property (nonatomic, strong) WBTweetModel *messageModel;

+ (CGFloat)heightForBubbleWithObject:(WBTweetModel *)object;
- (void)bubbleViewPressed:(id)sender;
@end
