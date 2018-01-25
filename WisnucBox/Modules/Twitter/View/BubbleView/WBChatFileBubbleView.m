//
//  WBChatFileBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/25.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatFileBubbleView.h"

@implementation WBChatFileBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        [self addSubview:self.imageView];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = CGSizeMake(self.messageModel.width, self.messageModel.height);//self.messageModel.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    } else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1 + BUBBLE_ARROW_WIDTH, 1 * BUBBLE_VIEW_PADDING + retSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, 2, 2);
    if (self.messageModel.isSender) {
        frame.origin.x = 2;
    } else {
        frame.origin.x = 2 + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = 2;
//    [self.imageView setFrame:frame];
}


#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(WBTweetModel *)object {
//    CGSize retSize = CGSizeMake(object.width, object.height);//object.size;
//    if (retSize.width == 0 || retSize.height == 0) {
//        retSize.width = MAX_SIZE;
//        retSize.height = MAX_SIZE;
//    } else if (retSize.width > retSize.height) {
//        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
//        retSize.height = height;
//        retSize.width = MAX_SIZE;
//    } else {
//        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
//        retSize.width = width;
//        retSize.height = MAX_SIZE;
//    }
    return 2 * BUBBLE_VIEW_PADDING + 56 + 20;
}
@end
