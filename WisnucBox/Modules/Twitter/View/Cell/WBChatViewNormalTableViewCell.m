//
//  WBChatViewNormalTableViewCell.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatViewNormalTableViewCell.h"

CGFloat const ACTIVTIYVIEW_BUBBLE_PADDING_X = 5.0f;
CGFloat const SEND_STATUS_SIZE_X = 20.0f;

@implementation WBChatViewNormalTableViewCell

- (id)initWithMessageModel:(WBTweetModel *)model reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier]) {
        self.headImageView.clipsToBounds = YES;
        self.headImageView.layer.cornerRadius = 20.0;
        if (model.isSender) {
             self.headImageView.layer.cornerRadius = 2.0;
        }
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y;
    
//    if (self.messageModel.isChatGroup) {
        bubbleFrame.origin.y = self.headImageView.frame.origin.y + NAME_LABEL_HEIGHT;
//    }
    if (self.messageModel.isSender) {
        bubbleFrame.origin.y = self.headImageView.frame.origin.y;
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.messageModel.status) {
            case MessageDeliveryState_Delivering:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case MessageDeliveryState_Delivered:
            {
                [_activtiy stopAnimating];
                [_activityView setHidden:YES];
                
            }
                break;
            case MessageDeliveryState_Failure:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - 8;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING_X;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING  + HEAD_SIZE + 8;
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)setMessageModel:(WBTweetModel *)model {
    [super setMessageModel:model];
    
//    if (model.isChatGroup) {
//        //        _nameLabel.text = [model.message.ext objectForKey:sendUserName];
//        _nameLabel.hidden = model.isSender;
//    }

    _bubbleView.messageModel = model;
    if ( model.messageBodytype == MessageBodyType_File) {
           [_bubbleView sizeToFit];
    }

}

- (void)prepareForReuse {
    [super prepareForReuse];
    if ([self.bubbleView isKindOfClass:[WBChatImageBubbleView class]]) {
        [((WBChatImageBubbleView *)self.bubbleView).subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [((WBChatImageBubbleView *)self.bubbleView).maskImageView removeFromSuperview];
        ((WBChatImageBubbleView *)self.bubbleView).maskImageView = nil;
    }
}

#pragma mark - action

// 重发按钮事件
- (void)retryButtonPressed:(UIButton *)sender {
    [self routerEventWithName:kRouterEventChatResendEventName
                     userInfo:@{kShouldResendCell : self}];
}

#pragma mark - private
- (void)setupSubviewsForMessageModel:(WBTweetModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE_X, SEND_STATUS_SIZE_X)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE_X, SEND_STATUS_SIZE_X);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[UIImage imageNamed:@"float_btn_del"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
    
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}

- (WBChatBaseBubbleView *)bubbleViewForMessageModel:(WBTweetModel *)messageModel {
    switch (messageModel.messageBodytype) {
        case MessageBodyType_Text: {
            return [[WBChatTextBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Image: {
            WBChatImageBubbleView *imageBubbleView = [[WBChatImageBubbleView alloc] initWithFrame:CGRectMake(0, 0, messageModel.width, messageModel.height)];
            imageBubbleView.refreshDelegate = self;
            return imageBubbleView;
        }
            break;
        case MessageBodyType_Voice: {
            return [[LHChatAudioBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Location: {
            return [[LHChatLocationBubbleView alloc] init];
        }
            break;
        case MessageBodyType_Video: {
            return [[LHChatVideoBubbleView alloc] init];
        }
            break;
        case MessageBodyType_File: {
            return [[WBChatFileBubbleView alloc] init];
        }
             break;
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(WBTweetModel *)messageModel {
    switch (messageModel.messageBodytype) {
        case MessageBodyType_Text: {
            return [WBChatTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Image: {
            return [WBChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Voice: {
            return [LHChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Location: {
            return [LHChatLocationBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_Video: {
            return [LHChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case MessageBodyType_File: {
            return  [WBChatFileBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        default:
            break;
    }
    
    return HEAD_SIZE;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(WBTweetModel *)model {
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_SIZE;
//    if (model.isChatGroup && !model.isSender) {
//        bubbleHeight += NAME_LABEL_HEIGHT;
//    }
    return MAX(headHeight, bubbleHeight);
}

- (void)reloadFinishLoadData{

}

@end
