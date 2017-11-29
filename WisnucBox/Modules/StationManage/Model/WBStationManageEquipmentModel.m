//
//  WBStationManageEquipmentModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageEquipmentModel.h"
@implementation WBStationManageWs215iModel

@end

@implementation WBStationManageCpuInfoModel

@end

@implementation WBStationManageMemInfoModel

@end

@implementation WBStationManageEquipmentModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"memInfo" : [WBStationManageMemInfoModel class],
             @"cpuInfo" : [WBStationManageCpuInfoModel class],
             @"ws215i" : [WBStationManageWs215iModel class]
             };
}
@end
