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
@property (nonatomic)WBStationManageVolumesUsageModel *usage;
@end

@interface WBStationManageStorageModel : WBBaseModel
@property (nonatomic) NSArray *volumes;
@end
