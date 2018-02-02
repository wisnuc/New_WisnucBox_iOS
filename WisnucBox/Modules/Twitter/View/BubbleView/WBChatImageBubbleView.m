//
//  WBChatImageBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatImageBubbleView.h"
#import "SDPhotoBrowser.h"
#define Width_Space      1.0f      // 2个图片之间的横间距
#define Height_Space     1.0f    // 竖间距
#define IMG_TWO_Height   134.0f    // 高
#define IMG_TWO_Width    134.0f    // 宽
#define IMG_THREE_Height   89.0f    // 高
#define IMG_THREE_Width    89.0f    // 宽
#define Start_X         0     // 第一个按钮的X坐标
#define Start_Y         0     // 第一个按钮的Y坐标

@interface WBChatImageBubbleView ()<UIGestureRecognizerDelegate,SDPhotoBrowserDelegate>



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
//    if (retSize.width == 0 || retSize.height == 0) {
//        retSize.width = MAX_SIZE;
//        retSize.height = MAX_SIZE;
//    }
//    if (retSize.width > retSize.height) {
//        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
//        retSize.height = height;
//        retSize.width = MAX_SIZE;
//    } else {
//        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
//        retSize.width = width;
//        retSize.height = MAX_SIZE;
//    }
//    NSLog(@"%@",NSStringFromCGSize(CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1, 1 * BUBBLE_VIEW_PADDING + retSize.height)));
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
    

//    self.backgroundColor = [UIColor blueColor];
//
}

- (float)setFrameSelfFrameWithArray:(NSArray *)array{
    float imageWithHeight = 0.0;
    CGRect frame = self.frame;
   if (array.count  == 0 || !array)return 0;
    if (array.count % 2 == 0) {
        if (array.count == 4) {
            frame.size.width = IMG_THREE_Width *2;
            imageWithHeight = IMG_THREE_Width;
        }else{
            frame.size.width = IMG_TWO_Width *2;
            imageWithHeight = IMG_TWO_Width;
        }
    }
    if (array.count % 3 == 0){
        frame.size.width = IMG_THREE_Width *3;
        imageWithHeight = IMG_THREE_Width;
    }
    if (array.count == 1) {
        frame.size.width = IMG_TWO_Width;
        imageWithHeight = IMG_TWO_Width;
    }
    
    if (array.count >=5) {
        frame.size.width = IMG_THREE_Width *3;
        imageWithHeight = IMG_THREE_Width;
    }
    
//        if (self.messageModel.isSender) {
//            frame.origin.x = 2;
//        } else {
////            frame.origin.x = 2 + BUBBLE_ARROW_WIDTH;
//        }

    dispatch_main_async_safe(^{
        self.frame = frame;
    });
    return imageWithHeight;
}


#pragma mark - setter

- (void)setMessageModel:(WBTweetModel *)messageModel {
    [super setMessageModel:messageModel];
    jy_weakify(self);
   
    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
    self.localImageArray = [[NSMutableArray alloc]initWithArray:messageModel.localImageArray copyItems:YES];
    if (!self.messageModel)return;
    float imageWithHeight = 0.0;
    if (messageModel.isSender) {
      imageWithHeight = [self setFrameSelfFrameWithArray:messageModel.localImageArray];
    }else{
      imageWithHeight = [self setFrameSelfFrameWithArray:messageModel.list];
    }

    
    if (messageModel.isSender && messageModel.localImageArray.count>0) {
        NSMutableArray *localImageArray = [NSMutableArray arrayWithArray:messageModel.localImageArray];
        if (localImageArray.count>6) {
            localImageArray = [NSMutableArray arrayWithArray:[messageModel.localImageArray subarrayWithRange:NSMakeRange(0, 6)]];
        }
        
        [localImageArray enumerateObjectsUsingBlock:^(WBTweetlocalImageModel *localImageModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.tag = idx;
            imageView.userInteractionEnabled = YES;
            
            NSInteger index = 0 ;
            NSInteger page = 0 ;
            
            if (messageModel.localImageArray.count == 1) {
                index = 0;
                page= 0;
            }else{
                if (messageModel.localImageArray.count % 2 == 0) {
                    index = idx % 2;
                    page= idx / 2;
                    
                }
                if (messageModel.localImageArray.count % 3 == 0){
                    index = idx % 3;
                    page= idx / 3;
                }
            }
            
            if (messageModel.localImageArray.count >=5) {
                index = idx % 3;
                page= idx / 3;
                NSLog(@"😆%ld🌶%ld",index,page);
            }
            //
            imageView.frame = CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
            [imageView addGestureRecognizer:tap];
            imageView.image = localImageModel.localImage;
          
            dispatch_main_async_safe(^{
            [weakSelf addSubview:imageView];
              });
            }];
        
        
      
        imageWithHeight = 89.0f;
        NSMutableArray *dataArray;
        if (messageModel.isSender) {
            dataArray = [NSMutableArray arrayWithArray:messageModel.localImageArray] ;
        }else{
            dataArray = [NSMutableArray arrayWithArray:messageModel.list];
        }
        if (dataArray.count >6) {
//            maskImageView.alpha = 0.54f;
            self.maskImageView.frame = CGRectMake(2 * (imageWithHeight + Width_Space) + Start_X,1 * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
            UILabel *label = [[UILabel alloc]initWithFrame:self.maskImageView.bounds];
            label.text = [NSString stringWithFormat:@"+%ld",dataArray.count - 6];
            label.font = [UIFont boldSystemFontOfSize:21];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = kWhiteColor;
            [self.maskImageView addSubview:label];
            dispatch_main_async_safe(^{
                [self addSubview:self.maskImageView];
            });
        }
        return;
    }
 

    imageWithHeight = [self setFrameSelfFrameWithArray:messageModel.list];
    
    
            if (self.thumbnailRequestOperationArray && self.thumbnailRequestOperationArray.count>0){
                [self.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(id <SDWebImageOperation> thumbnailRequestOperation, NSUInteger idx, BOOL * _Nonnull stop) {
                    [thumbnailRequestOperation cancel];
                }];
            }
            [self.thumbnailRequestOperationArray removeAllObjects];
            self.thumbnailRequestOperationArray = nil;
//            _imageView.image = image;
            NSLog(@"🍰%ld",messageModel.list.count);
            
            NSMutableArray *imageArray = [NSMutableArray arrayWithArray:messageModel.list];
            if (imageArray.count>6) {
                imageArray = [NSMutableArray arrayWithArray:[messageModel.list subarrayWithRange:NSMakeRange(0, 6)]];
            }
            
            NSLog(@"😝%ld",imageArray.count);
          
            [imageArray enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {
             
                UIImageView *imageView = [[UIImageView alloc]init];
                imageView.tag = idx;
                imageView.userInteractionEnabled = YES;
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
                
                if (messageModel.list.count >=5) {
                    index = idx % 3;
                    page= idx / 3;
                    NSLog(@"😆%ld🌶%ld",index,page);
                }
//                NSLog(@"😆%ld",index);
                imageView.frame = CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
                [imageView addGestureRecognizer:tap];
                
                
//                NSLog(@"🌶%@",NSStringFromCGRect(_imageView.frame));
//                dispatch_main_async_safe(^{
//                    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
                    imageView.image = image;
//                });
                  [weakSelf addSubview:imageView];
                 NSString *date = [NSString stringWithFormat:@"%@%lld%ld",messageModel.uuid,messageModel.ctime,idx];
                [SDImageCache.sharedImageCache diskImageExistsWithKey:date completion:^(BOOL isInCache) {
                    if (isInCache) {
                        [SDImageCache.sharedImageCache queryDiskCacheForKey:date done:^(UIImage *image, SDImageCacheType cacheType) {
                            
                            dispatch_main_async_safe(^{
                            self.imageView.image = image;
                            });
                            NSLog(@"%@",image);
                        }];
                    }else{
                 
               __block id <SDWebImageOperation> thumbnailRequestOperation = [WB_NetService getTweeetThumbnailImageWithHash:listModel.sha256 BoxUUID:messageModel.boxuuid complete:^(NSError *error, UIImage *img) {
                    if(!weakSelf) return;
                   UIImage *imageCache = (UIImage *)img;
                   messageModel.width = imageCache.size.width;
                   messageModel.height = imageCache.size.height;
                   [SDImageCache.sharedImageCache storeImage:imageCache forKey:[NSString stringWithFormat:@"%@%lld%ld",messageModel.uuid,messageModel.ctime,imageView.tag] toDisk:YES];
                    if (!error &&img) {
                        dispatch_main_async_safe(^{
                            imageView.image = img;
                            
                        });
                        
                        [self.thumbnailRequestOperationArray addObject:thumbnailRequestOperation];
                    
                    }else{
                        dispatch_main_async_safe(^{
                            imageView.image = image;
//
                        });
                        NSLog(@"get thumbnail error ---> : %@", error);
                        [self.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(id <SDWebImageOperation> thumbnailRequestOperationIn, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([thumbnailRequestOperationIn isEqual:thumbnailRequestOperation]) {
                              [thumbnailRequestOperationIn cancel];
                            }
                        }];
                    }
                   [self.imageArray addObject:imageView];
                }];
            }
        }];
    }];
    
    
    
    imageWithHeight = 89.0f;
    NSMutableArray *dataArray;
    if (messageModel.isSender) {
        dataArray = [NSMutableArray arrayWithArray:messageModel.localImageArray] ;
    }else{
        dataArray = [NSMutableArray arrayWithArray:messageModel.list];
    }
    if (dataArray.count >6) {

//        maskImageView.alpha = 0.6f;
        self.maskImageView.frame = CGRectMake(2 * (imageWithHeight + Width_Space) + Start_X,1 * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
        dispatch_main_async_safe(^{
        [self addSubview:self.maskImageView];
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
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
//    else if (retSize.width > retSize.height) {
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
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIImageView *imageView = (UIImageView *)tap.view;
    
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.messageModel.list.count;
    if (self.messageModel.isSender && self.localImageArray.count>0) {
        browser.imageCount = self.localImageArray.count;
    }
    browser.delegate = self;
    [browser show];
//    [self routerEventWithName:kRouterEventImageBubbleTapEventName
//                     userInfo:@{kMessageKey : self.messageModel,kMessageImageKey:imageView}];
}

- (UIImageView *)maskImageView{
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.54f)]];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
        [_maskImageView addGestureRecognizer:tap];
    }
    return _maskImageView;
}

//- (UIImageView *)imageView{
//    if (!_imageView) {
//       _imageView = [[UIImageView alloc] init];
//    }
//    return _imageView;
//}

- (NSMutableArray *)imageArray{
    if (!_imageArray) {
        _imageArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArray;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}

- (NSDictionary *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageBoxInfoForIndex:(NSInteger)index{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
  
    if (self.localImageArray.count>0) {
       WBTweetlocalImageModel *localImageModel = self.localImageArray[index];
        [dic setObject:localImageModel.asset forKey:kMessageImageBoxLocalAsset];
        return dic;
    }
    
    [dic setObject:self.messageModel.boxuuid forKey:kMessageImageBoxUUID];
    [dic setObject:((WBTweetlistModel *)self.messageModel.list[index]).sha256 forKey:kMessageImageBoxNetImageHash];
    return dic;
}

@end

