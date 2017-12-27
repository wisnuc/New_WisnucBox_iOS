//
//  WBStationManageStorageModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface WBStationManageVolumesUsageModel : NSObject
@property (nonatomic) NSDictionary *data;
@property (nonatomic) NSDictionary *overall;
@end

@interface WBStationManageVolumesModel : NSObject
@property (nonatomic,copy) NSNumber *total;
@property (nonatomic,copy) NSNumber *isBtrfs;
@property (nonatomic,copy) NSNumber *isMissing;
@property (nonatomic,copy) NSNumber *isMounted;
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic,copy) id users;
@property (nonatomic)WBStationManageVolumesUsageModel *usage;
@end

@interface WBStationManageBlocksModel : NSObject
@property (nonatomic,copy) NSString *model;
@property (nonatomic,copy) NSNumber *isDisk;
@property (nonatomic,copy) NSNumber *isATA;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSNumber *size;
@property (nonatomic,copy) NSNumber *isFileSystem;
@property (nonatomic,copy) NSString *unformattable;
@property (nonatomic,copy) NSString *idBus;
@property (nonatomic,copy) NSString *fileSystemType;
@property (nonatomic,copy) NSNumber *isPartitioned;
@property (nonatomic,copy) NSNumber *removable;

@end

@interface WBStationManageStorageModel : WBBaseModel
@property (nonatomic) NSArray *volumes;
@property (nonatomic) NSArray *blocks;
//devname = "/dev/sdc2";
//idBus = ata;
//isATA = 1;
//isExtended = 1;
//isPartition = 1;
//isDisk = 1;
//name = sdc2;
//parentName = sdc;
//path = "/devices/pci0000:00/0000:00:1f.2/ata8/host7/target7:0:0/7:0:0:0/block/sdc/sdc2";
//removable = 0;
//size = 2;
//unformattable = Extended;
@end
