//
//  WBStationManageNetInterfacesModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface IpAddressesModel : NSObject

@property (copy,nonatomic) NSString *address;
@property (copy,nonatomic) NSString *cidr;
@property (copy,nonatomic) NSString *family;
@property (copy,nonatomic) NSNumber *internal;
@property (copy,nonatomic) NSString *mac;
@property (copy,nonatomic) NSString *netmask;
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSNumber *speed;
@end

@interface WBStationManageNetInterfacesModel : WBBaseModel
@property (copy,nonatomic) NSString *address;
@property (strong,nonatomic)NSArray *ipAddresses;
@property (copy,nonatomic) NSString *up;
@property (copy,nonatomic) NSNumber *wireless;
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSNumber *speed;
@end
