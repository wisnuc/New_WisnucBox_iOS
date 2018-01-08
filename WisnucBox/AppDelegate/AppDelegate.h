//
//  AppDelegate.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMLeftManager.h"
#import "JYThumbVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) dispatch_block_t completeBlock;

@property (nonatomic) FMLeftManager *leftManager;

- (void)initRootVC;
- (void)leftMenuReloadData;
@end

