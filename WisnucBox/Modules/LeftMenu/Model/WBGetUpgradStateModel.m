//
//  WBGetUpgradStateModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBGetUpgradStateModel.h"

@implementation WBGetUpgradStateRemoteModel : NSObject

@end

@implementation WBGetUpgradStateReleasesModel

@end

@implementation WBGetUpgradStateAppifiModel

@end

@implementation WBGetUpgradStateModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"releases" : [WBGetUpgradStateReleasesModel class],
             };
}
@end
