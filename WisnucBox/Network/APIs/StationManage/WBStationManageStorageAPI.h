//
//  WBStationManageStorageAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:GET STATION STORAGE INFO
 */
@interface WBStationManageStorageAPI : JYBaseRequest
@property(nonatomic,copy) NSString *path;
+(instancetype)apiWithURLPath:(NSString *)path;
@end
