//
//  FLGetDriveDirAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FLGetDriveDirAPI : JYBaseRequest

@property (nonatomic) NSString * driveUUID;

@property (nonatomic) NSString * dirUUID;

/*
 * WISNUC API:GET DRIVES DIRECTORY INFO
 * @param driveUUID   Drive UUID
 * @param dirUUID     Directory UUID
 */
+ (instancetype)apiWithDrive:(NSString *)driveUUID dir:(NSString *)dirUUID;

@end
