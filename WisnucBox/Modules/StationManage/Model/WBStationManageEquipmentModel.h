//
//  WBStationManageEquipmentModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface WBStationManageWs215iModel : NSObject
@property (nonatomic,copy) NSString *mac;
@property (nonatomic,copy) NSString *serial;
@end

@interface WBStationManageCpuInfoModel : NSObject
@property (nonatomic,copy) NSString *modelName;
@property (nonatomic,copy) NSString *cacheSize;
@end

@interface WBStationManageMemInfoModel : NSObject
@property (nonatomic,copy) NSString *memFree;
@property (nonatomic,copy) NSString *memTotal;
@property (nonatomic,copy) NSString *memAvailable;
@end


@interface WBStationManageEquipmentModel : WBBaseModel
@property (nonatomic) WBStationManageMemInfoModel *memInfo;
@property (nonatomic) NSArray *cpuInfo;
@property (nonatomic) WBStationManageWs215iModel *ws215i;
@end

