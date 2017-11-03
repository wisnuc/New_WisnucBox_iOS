//
//  JYForveTouchPreviewController.h
//  Photos
//
//  Created by JackYang on 2017/10/17.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYAsset;
@interface JYForceTouchPreviewController : UIViewController

@property (nonatomic, assign) BOOL allowSelectGif;
@property (nonatomic, assign) BOOL allowSelectLivePhoto;
@property (nonatomic, strong) JYAsset *model;

@end
