//
//  WBChatImageBubbleView.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "WBChatImageBubbleView.h"
#import "SDPhotoBrowser.h"
#import "JYThumbVC.h"
#import "MWPhotoBrowser.h"
#define Width_Space      1.0f      // 2个图片之间的横间距
#define Height_Space     1.0f    // 竖间距
#define IMG_TWO_Height   134.0f    // 高
#define IMG_TWO_Width    134.0f    // 宽
#define IMG_THREE_Height   89.0f    // 高
#define IMG_THREE_Width    89.0f    // 宽
#define Start_X         0     // 第一个按钮的X坐标
#define Start_Y         0     // 第一个按钮的Y坐标

@interface WBChatImageBubbleView ()<UIGestureRecognizerDelegate,SDPhotoBrowserDelegate,MWPhotoBrowserDelegate>

@property (nonatomic,strong) NSMutableArray *photoArray;
@property (nonatomic,strong) NSMutableArray *thumbArray;

@end

@implementation WBChatImageBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

//        [self addSubview:self.imageView];
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize retSize = CGSizeMake(self.messageModel.width, self.messageModel.height);//self.messageModel.size;
    NSLog(@"%@",NSStringFromCGSize(retSize));
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
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
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 1, 1 * BUBBLE_VIEW_PADDING + retSize.height);
}

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
    

//    self.backgroundColor = [UIColor whiteColor];
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
    if (self.imageArray) {
        [_imageArray removeAllObjects];
    }
    UIImage *image = [UIImage imageNamed:@"IM_Chart_imageDownloadFail.png"];
    self.localImageArray = [[NSMutableArray alloc]initWithArray:messageModel.localImageArray copyItems:YES];
    if (!self.messageModel)return;
    float imageWithHeight = 0.0;
    if (messageModel.isSender) {
      imageWithHeight = [self setFrameSelfFrameWithArray:messageModel.localImageArray];
    }else{
      imageWithHeight = [self setFrameSelfFrameWithArray:messageModel.list];
    }

    if (messageModel.isSender && messageModel.localImageArray.count==0){
        
    }
    
    if (messageModel.isSender && messageModel.localImageArray.count>0) {
        NSMutableArray *localImageArray = [NSMutableArray arrayWithArray:messageModel.localImageArray];
//        if (localImageArray.count>6) {
//            localImageArray = [NSMutableArray arrayWithArray:[messageModel.localImageArray subarrayWithRange:NSMakeRange(0, 6)]];
//        }
        
        [localImageArray enumerateObjectsUsingBlock:^(WBTweetlocalImageModel *localImageModel, NSUInteger idx, BOOL * _Nonnull stop) {

        
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
            }
            //
            UIImageView *imageView ;
            if (idx<=5) {
           imageView = [[UIImageView alloc]init];
            imageView.tag = idx;
            imageView.userInteractionEnabled = YES;
            
            imageView.frame = CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight);
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
            [imageView addGestureRecognizer:tap];
            imageView.image = localImageModel.localImage;
        
            }
            dispatch_main_async_safe(^{
                [weakSelf addSubview:imageView];
            });
            [self.imageArray addObject:localImageModel.localImage];
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
                [self.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(SDWebImageDownloadToken *thumbnailRequestOperation, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[SDWebImageDownloader sharedDownloader] cancel:thumbnailRequestOperation];
                }];
            }
            [self.thumbnailRequestOperationArray removeAllObjects];
            self.thumbnailRequestOperationArray = nil;
//            _imageView.image = image;
//            NSLog(@"🍰%ld",messageModel.list.count);
    
            NSMutableArray *imageArray = [NSMutableArray arrayWithArray:messageModel.list];
//            if (imageArray.count>6) {
//                imageArray = [NSMutableArray arrayWithArray:[messageModel.list subarrayWithRange:NSMakeRange(0, 6)]];
//            }
    
//           NSLog(@"😝");
    
            [imageArray enumerateObjectsUsingBlock:^(WBTweetlistModel *listModel, NSUInteger idx, BOOL * _Nonnull stop) {
              NSLog(@"😝%ld",idx);
           
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

                }
               
                UIImageView *imageView;
                if (idx <=5) {
                imageView = [[UIImageView alloc]initWithFrame:CGRectMake(index * (imageWithHeight + Width_Space) + Start_X,page * (imageWithHeight + Height_Space)+Start_Y, imageWithHeight, imageWithHeight)];
                imageView.tag = idx;
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewPressed:)];
                [imageView addGestureRecognizer:tap];
                imageView.image = image;
                }
                NSString *key = [NSString stringWithFormat:@"%@%lld%ld",messageModel.uuid,messageModel.ctime,idx];
                [SDImageCache.sharedImageCache diskImageExistsWithKey:key completion:^(BOOL isInCache) {
                    if (isInCache) {
                        [SDImageCache.sharedImageCache queryCacheOperationForKey:key done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                            dispatch_main_async_safe(^{
                                imageView.image = image;
                                [weakSelf.imageArray addObject:image];
                            });
                        }];
                    }else{
               __block SDWebImageDownloadToken *thumbnailDownloadToken = [WB_NetService getTweeetThumbnailImageWithHash:listModel.sha256 BoxUUID:messageModel.boxuuid complete:^(NSError *error, UIImage *img) {
                    if(!weakSelf) return;
                    if (!error &&img) {
                        [SDImageCache.sharedImageCache storeImage:img forKey:[NSString stringWithFormat:@"%@%lld%ld",messageModel.uuid,messageModel.ctime,imageView.tag] toDisk:YES completion:^{
                        }];
                        
                        dispatch_main_async_safe(^{
                            imageView.image = img;
                            [weakSelf.imageArray addObject:img];
                        });
             
                        [weakSelf.thumbnailRequestOperationArray addObject:thumbnailDownloadToken];
                    
                    }else{
                        dispatch_main_async_safe(^{
                            imageView.image = image;
                             [weakSelf.imageArray addObject:image];
                        });
                        NSLog(@"get thumbnail error ---> : %@", error);
                        [weakSelf.thumbnailRequestOperationArray enumerateObjectsUsingBlock:^(SDWebImageDownloadToken * thumbnailDownloadTokenIn, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([thumbnailDownloadTokenIn isEqual:thumbnailDownloadToken]) {
                                [[SDWebImageDownloader sharedDownloader] cancel:thumbnailDownloadTokenIn];
                            }
                        }];
                    }
                }];
            }
        }];
//                NSLog(@"🌶%@",imageView);
              
                if (idx <=5) {
                       [weakSelf addSubview:imageView];
                }
             
    }];
    
    
    
    imageWithHeight = 89.0f;
    NSMutableArray *dataArray;
    if (messageModel.isSender) {
        dataArray = [NSMutableArray arrayWithArray:messageModel.localImageArray] ;
        [dataArray addObjectsFromArray:messageModel.list];
    }else{
        dataArray = [NSMutableArray arrayWithArray:messageModel.list];
    }
    if (dataArray.count >6) {
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
    }
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

- (void)maskViewPressed:(id)sender{
    NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:0];
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MWPhoto *photo = [MWPhoto photoWithImage:obj];
        [photoArray addObject:photo];
    }];
    self.thumbArray = photoArray;
    
    NSMutableArray *highQualityphotosArray = [NSMutableArray arrayWithCapacity:0];
    if (self.messageModel.isSender) {
        [self.messageModel.localImageArray enumerateObjectsUsingBlock:^(WBTweetlocalImageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[WBAsset class]]) {
                WBAsset * asset = obj.asset;
                MWPhoto *photo = [MWPhoto photoHighImageWithHash:asset.fmhash];
                [highQualityphotosArray addObject:photo];
            }else{
                JYAsset * jyasset = obj.asset;
                MWPhoto *photo = [MWPhoto photoWithAsset:jyasset.asset targetSize:CGSizeMake(jyasset.asset.pixelWidth, jyasset.asset.pixelHeight)];
                [highQualityphotosArray addObject:photo];
            }
        }];
        [self.messageModel.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MWPhoto *photo = [MWPhoto photoGetQualityImageWithHash:obj.sha256 BoxUUID:self.messageModel.boxuuid];
            [highQualityphotosArray addObject:photo];
        }];
    }else{
        [self.messageModel.list enumerateObjectsUsingBlock:^(WBTweetlistModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MWPhoto *photo = [MWPhoto photoGetQualityImageWithHash:obj.sha256 BoxUUID:self.messageModel.boxuuid];
            [highQualityphotosArray addObject:photo];
        }];
    }
     self.photoArray = highQualityphotosArray;
//    if (self.messageModel.isSender) {
//        [photoArray addObjectsFromArray:self.localImageArray] ;
//        [photoArray addObjectsFromArray:self.messageModel.list];
//    }else{
//        [photoArray addObjectsFromArray:self.messageModel.list];
//    }
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    photoBrowser.displayActionButton = NO;//显示分享按钮(左右划动按钮显示才有效)
    photoBrowser.displayNavArrows = YES; //显示左右划动
    photoBrowser.alwaysShowControls = NO; //控制条始终显示
    photoBrowser.zoomPhotosToFill = YES; //是否自适应大小
    photoBrowser.startOnGrid = YES; //是否以网格开始;
    photoBrowser.enableSwipeToDismiss = YES;
    photoBrowser.autoPlayOnAppear = NO;//是否自动播放视频
    photoBrowser.enableGrid = YES;
    photoBrowser.displayActionButton = YES;
    [photoBrowser showNextPhotoAnimated:YES];
    [photoBrowser showPreviousPhotoAnimated:YES];

    [[UIViewController getCurrentVC].navigationController pushViewController:photoBrowser animated:YES];
}

- (UIImageView *)maskImageView{
    if (!_maskImageView) {
        _maskImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithColor:RGBACOLOR(0, 0, 0, 0.54f)]];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewPressed:)];
        [_maskImageView addGestureRecognizer:tap];
        _maskImageView.userInteractionEnabled = YES;
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

- (NSMutableArray *)photoArray{
    if (!_photoArray) {
        _photoArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _photoArray;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    NSLog(@"%@",self.subviews);
    UIImageView *imageView = self.subviews[index];

    return imageView.image;
}

- (NSDictionary *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageBoxInfoForIndex:(NSInteger)index{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
  
    if (self.messageModel.localImageArray.count>0) {
       WBTweetlocalImageModel *localImageModel = self.messageModel.localImageArray[index];
        [dic setObject:localImageModel.asset forKey:kMessageImageBoxLocalAsset];
        return dic;
    }
    
    [dic setObject:self.messageModel.boxuuid forKey:kMessageImageBoxUUID];
    [dic setObject:((WBTweetlistModel *)self.messageModel.list[index]).sha256 forKey:kMessageImageBoxNetImageHash];
    return dic;
}

#pragma mark - MWPhotosBrowserDelegate
//必须实现的方法
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return  self.photoArray.count;
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    if (index < self.photoArray.count) {
        return [self.photoArray objectAtIndex:index];
    }
    return nil;
}
//可选方法
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index{
    NSLog(@"当前显示图片编号----%ld",index);
}
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index{
    NSLog(@"分享按钮的点击方法----%ld",index);
}


//有navigationBar时title才会显示
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index{
    
    NSString *str = [NSString stringWithFormat:@"%ld/%ld",index,self.photoArray.count];
    return str;
}
//如果要看缩略图必须实现这个方法
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    return [self.thumbArray objectAtIndex:index];
}
-(void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser{
    
    [[UIViewController getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
}

@end

