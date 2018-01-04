//
//  FMSetting.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBFeaturesDlnaStatusAPI.h"
#import "WBFeaturesSambaStatusAPI.h"
#import "WBFeaturesChangeAPI.h"

@interface FMSetting : FABaseVC
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
- (instancetype)initPrivate;
@end
