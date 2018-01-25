//
//  WBChatImageBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatImageBubbleView.h"

@interface WBChatImageBubbleView ()



@end

@implementation WBChatImageBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
   
        [self addSubview:self.imageView];
        
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
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setMessageModel:(WBTweetModel *)messageModel {
    [super setMessageModel:messageModel];
    jy_weakify(self);
    NSString *date = [NSString stringWithFormat:@"%lld",messageModel.ctime];
    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
    
    [SDImageCache.sharedImageCache diskImageExistsWithKey:date completion:^(BOOL isInCache) {
        if (isInCache) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:date] placeholderImage:image];
        }else{
            if (self.thumbnailRequestOperationArray && self.thumbnailRequestOperationArray.count>0){
                [self.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(id <SDWebImageOperation> thumbnailRequestOperation, NSUInteger idx, BOOL * _Nonnull stop) {
                    [thumbnailRequestOperation cancel];
                }];
            }
            
            [self.thumbnailRequestOperationArray removeAllObjects];
            self.thumbnailRequestOperationArray = nil;
            weakSelf.imageView.image = image;
            [messageModel.list enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {

               __block id <SDWebImageOperation> thumbnailRequestOperation = [WB_NetService getTweeetThumbnailImageWithHash:listModel.sha256 BoxUUID:messageModel.boxuuid complete:^(NSError *error, UIImage *img) {
                   if(!weakSelf) return;
                    if (!error) {
                        dispatch_main_async_safe(^{
                            weakSelf.imageView.image = img;
                            [weakSelf setNeedsLayout];
                        });
                        
                        [self.thumbnailRequestOperationArray addObject:thumbnailRequestOperation];
                        
                    }else{
                        NSLog(@"get thumbnail error ---> : %@", error);
                        [self.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(id <SDWebImageOperation> thumbnailRequestOperationIn, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([thumbnailRequestOperationIn isEqual:thumbnailRequestOperation]) {
                              [thumbnailRequestOperationIn cancel];
                            }
                        }];
                    }
                }];
            }];
        }
    }];
    
    
//     if (messageModel.isSender) {
//     if (messageModel.imageRemoteURL) {
//     [SDImageCache.sharedImageCache diskImageExistsWithKey:date completion:^(BOOL isInCache) {
//     if (isInCache) {
//     [self.imageView sd_setImageWithURL:[NSURL URLWithString:date] placeholderImage:image];
//     return;
//     }
//     [self.imageView sd_setImageWithURL:messageModel.imageRemoteURL placeholderImage:image];
//     }];
//     } else {
//     [self.imageView sd_setImageWithURL:[NSURL URLWithString:date] placeholderImage:image];
//     }
//     return;
//     }
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(WBTweetModel *)object {
    CGSize retSize = CGSizeMake(object.width, object.height);//object.size;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    } else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = height;
        retSize.width = MAX_SIZE;
    } else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = width;
        retSize.height = MAX_SIZE;
    }
    return 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
        _imageView = [[UIImageView alloc] initWithImage:image];
//        _imageView.layer.cornerRadius = 14;
//        _imageView.layer.masksToBounds= YES;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

@end

