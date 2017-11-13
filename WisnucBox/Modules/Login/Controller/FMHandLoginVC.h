//
//  FMHandLoginVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FABaseVC.h"
#import "FMSerachService.h"

typedef void(^HandlecompleteBlock)(FMSerachService * service);

@interface FMHandLoginVC : FABaseVC
@property (nonatomic, copy) HandlecompleteBlock block;
@end
