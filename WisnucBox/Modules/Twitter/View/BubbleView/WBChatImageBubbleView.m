//
//  WBChatImageBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatImageBubbleView.h"
#define Width_Space      1.0f      // 2个图片之间的横间距
#define Height_Space     1.0f    // 竖间距
#define IMG_TWO_Height   134.0f    // 高
#define IMG_TWO_Width    134.0f    // 宽
#define IMG_THREE_Height   89.0f    // 高
#define IMG_THREE_Width    89.0f    // 宽
#define Start_X         0     // 第一个按钮的X坐标
#define Start_Y         0     // 第一个按钮的Y坐标

@interface WBChatImageBubbleView ()



@end

@implementation WBChatImageBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

//        [self addSubview:self.imageView];
        
    }
    return self;
}


//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize retSize = CGSizeMake(self.messageModel.width, self.messageModel.height);//self.messageModel.size;
////    if (retSize.width == 0 || retSize.height == 0) {
////        retSize.width = MAX_SIZE;
////        retSize.height = MAX_SIZE;
////    }
////    if (retSize.width > retSize.height) {
////        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
////        retSize.height = height;
////        retSize.width = MAX_SIZE;
////    } else {
////        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
////        retSize.width = width;
////        retSize.height = MAX_SIZE;
////    }
////    NSLog(@"%@",NSStringFromCGSize(CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1, 1 * BUBBLE_VIEW_PADDING + retSize.height)));
//    return CGSizeMake(retSize.width , retSize.height);
//}

- (void)layoutSubviews {
    [super layoutSubviews];
//
//    CGRect frame = self.bounds;
////    frame.size.width -= BUBBLE_ARROW_WIDTH;
//    frame = CGRectInset(frame, 2, 2);
////    if (self.messageModel.isSender) {
//        frame.origin.x = 2;
////    } else {
////        frame.origin.x = 2 + BUBBLE_ARROW_WIDTH;
////    }
//
//    frame.origin.y = 2;
//    [self.imageView setFrame:frame];
    

    self.backgroundColor = [UIColor blueColor];
//
}


#pragma mark - setter

- (void)setMessageModel:(WBTweetModel *)messageModel {
    [super setMessageModel:messageModel];
    jy_weakify(self);
    NSString *date = [NSString stringWithFormat:@"%lld",messageModel.ctime];
    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
    
    CGRect frame = self.frame;
    if (!self.messageModel)return;
    float imageWithHeight = 0.0;
    if (messageModel.list.count  == 0 || !messageModel.list)return;
    
    if (messageModel.list.count % 2 == 0) {
        if (messageModel.list.count == 4) {
            frame.size.width = IMG_THREE_Width *2;
            imageWithHeight = IMG_THREE_Width;
        }else{
        frame.size.width = IMG_TWO_Width *2;
        imageWithHeight = IMG_TWO_Width;
        }
    }
    if (messageModel.list.count % 3 == 0){
        frame.size.width = IMG_THREE_Width *3;
        imageWithHeight = IMG_THREE_Width;
    }
    if (self.messageModel.list.count == 1) {
        frame.size.width = IMG_THREE_Width;
        imageWithHeight = IMG_TWO_Width;
    }
    
    if (self.messageModel.list.count >=6) {
       frame.size.width = IMG_THREE_Width *3;
       imageWithHeight = IMG_THREE_Width;
    }
    
    dispatch_main_async_safe(^{
       self.frame = frame;
      [weakSelf setNeedsLayout];
    });
    
 
    
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
//            weakSelf.imageView.image = image;
            NSLog(@"🍰%ld",messageModel.list.count);
            
            NSMutableArray *imageArray = [NSMutableArray arrayWithArray:messageModel.list];
            if (imageArray.count>6) {
                imageArray = [NSMutableArray arrayWithArray:[messageModel.list subarrayWithRange:NSMakeRange(0, 6)]];
            }
            
            NSLog(@"😝%ld",imageArray.count);
          
            [imageArray enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {
               
                weakSelf.imageView = [[UIImageView alloc] init];
                weakSelf.imageView.tag = idx;
                weakSelf.imageView.userInteractionEnabled = YES;
                NSInteger index = 0 ;
                NSInteger page = 0 ;
                
               if (messageModel.list.count == 1) {
                    index = 0;
                    page= 0;
                }else{
                    if (messageModel.list.count % 2 == 0) {
                        index = idx % 2;
                        page= idx / 2;
                        
                    }
                    if (messageModel.list.count % 3 == 0){
                        index = idx % 3;
                        page= idx / 3;
                    }
                }
                
                if (messageModel.list.count >= 6) {
                    index = idx % 3;
                    page= idx / 3;
                }
//                NSLog(@"😆%ld",index);
                weakSelf.imageView.frame = CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
                [weakSelf.imageView addGestureRecognizer:tap];
                
                
                NSLog(@"🌶%@",NSStringFromCGRect(weakSelf.imageView.frame));
                dispatch_main_async_safe(^{
                    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
                    weakSelf.imageView.image = image;
                    [weakSelf setNeedsLayout];
                });
                
                [weakSelf addSubview:weakSelf.imageView];
              
               __block id <SDWebImageOperation> thumbnailRequestOperation = [WB_NetService getTweeetThumbnailImageWithHash:listModel.sha256 BoxUUID:messageModel.boxuuid complete:^(NSError *error, UIImage *img) {
                    if(!weakSelf) return;
                    if (!error &&img) {
                        dispatch_main_async_safe(^{
                            weakSelf.imageView.image = img;
                            [weakSelf setNeedsLayout];
                        });
                        
                        [self.thumbnailRequestOperationArray addObject:thumbnailRequestOperation];
                        
                    }else{
                        dispatch_main_async_safe(^{
                            weakSelf.imageView.image = image;
                            [weakSelf setNeedsLayout];
                        });
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
    UIImageView * maskImageView ;
    imageWithHeight = 89.0f;
    if (messageModel.list.count >6) {
        maskImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithColor:[UIColor blackColor]]];
//        maskImageView.alpha = 0.6f;
        maskImageView.frame = CGRectMake(5 * (imageWithHeight + Width_Space) + Start_X,2 * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
        dispatch_main_async_safe(^{
        [self addSubview:maskImageView];
        });
    }
    
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
//    NSInteger duration = 0;
//    if (object.list.count%2==0) {
//        duration = (NSInteger)round(object.list.count/2);
//    }else if (object.list.count%3==0){
//        duration = (NSInteger)round(object.list.count/3);
//    }
    
    return 2 * BUBBLE_VIEW_PADDING + retSize.height + 20;
}

- (void)bubbleViewPressed:(id)sender {
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{kMessageKey : self.messageModel}];
}

//- (UIImageView *)imageView{
//    if (!_imageView) {
//
//    }
//    return _imageView;
//}

@end

