//
//  WBStationManageNetInterfacesModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBStationManageNetInterfacesModel.h"

@implementation WBStationManageNetInterfacesModel

- (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    return @{
             @"ipAddresses":IpAddressesModel.class
             };
}

@end

@implementation IpAddressesModel


@end
