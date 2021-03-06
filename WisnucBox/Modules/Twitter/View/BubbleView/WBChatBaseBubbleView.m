//
//  WBChatBaseBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatBaseBubbleView.h"


// bubbleView 的背景图片
NSString *const BUBBLE_LEFT_IMAGE_NAME_X = @"IM_Chat_receiver_bg";
NSString *const BUBBLE_RIGHT_IMAGE_NAME_X = @"IM_Chat_sender_bg";

@interface WBChatBaseBubbleView ()

@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation WBChatBaseBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self addSubview:self.backImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)setMessageModel:(WBTweetModel *)messageModel {
    _messageModel = messageModel;
    
    BOOL isReceiver = !messageModel.isSender;
//    NSString *imageName = isReceiver ? BUBBLE_LEFT_IMAGE_NAME_X : BUBBLE_RIGHT_IMAGE_NAME_X;
//    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger leftCapWidth = isReceiver?BUBBLE_LEFT_LEFT_CAP_WIDTH:BUBBLE_RIGHT_LEFT_CAP_WIDTH;
    NSInteger topCapHeight =  isReceiver?BUBBLE_LEFT_TOP_CAP_HEIGHT:BUBBLE_RIGHT_TOP_CAP_HEIGHT;
//
//    UIImage *image = [UIImage imageNamed:imageName];
//    NSInteger bottomCapHeight = image.size.height - topCapHeight - 1;
//    NSInteger rightCapWidth = image.size.width - leftCapWidth -1;
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, bottomCapHeight, rightCapWidth)];
    
//    UIImage *image = [UIImage imageWithColor:kWhiteColor];
//    NSInteger bottomCapHeight = image.size.height - topCapHeight - 1;
//    NSInteger rightCapWidth = image.size.width - leftCapWidth -1;
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, bottomCapHeight, rightCapWidth)];
//    self.backImageView.image = image;
}

#pragma mark - public
+ (CGFloat)heightForBubbleWithObject:(WBTweetModel *)object {
    return 40;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventChatCellBubbleTapEventName userInfo:@{kMessageKey : self.messageModel}];
}

#pragma mark - lazy
- (UIImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _backImageView;
}

@end
