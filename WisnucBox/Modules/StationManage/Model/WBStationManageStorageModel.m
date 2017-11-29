//
//  WBStationManageStorageModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageStorageModel.h"
@implementation WBStationManageVolumesUsageModel

@end

@implementation WBStationManageVolumesModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"usage" : [WBStationManageVolumesUsageModel class],
             };
}
@end


@implementation WBStationManageStorageModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"volumes" : [WBStationManageVolumesModel class],
             };
}
@end
