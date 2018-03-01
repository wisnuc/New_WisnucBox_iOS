//
//  WBStorageVolumesAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBStorageVolumesAPI : JYBaseRequest
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *mode;
@property(nonatomic) NSArray *target;
/*
 * WISNUC API:INITIALIZE DISK
 * @param path     URL
 * @param target   Disk Name Array
 * @param mode     Initialize DISK Mode (single,raid0,raid1)
 */
+(instancetype)apiWithURLPath:(NSString *)path Target:(NSArray *)target Mode:(NSString *)mode;
@end
