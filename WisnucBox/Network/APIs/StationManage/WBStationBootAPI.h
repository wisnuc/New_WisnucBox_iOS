//
//  WBStationBootAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBStationBootAPI : JYBaseRequest
@property (nonatomic) NSString * state;
@property (nonatomic) NSString * mode;
@property (nonatomic) NSString * mothod;
@property (nonatomic) NSString * path;
@property (nonatomic) NSString * uuid;

/*
 * WISNUC API:STATION BOOT ACTION
 * @param state     Action(poweroff,reboot)
 * @param mode      Mode(maintenance)
 */

+ (instancetype)apiWithState:(NSString *)state Mode:(NSString *)mode;
/*
 * WISNUC API:GET STATION BOOT INFO
 */
+ (instancetype)apiWithPath:(NSString *)path RequestMethod:(NSString *)mothod;
/*
 * WISNUC API:INSTALL STATION SYSTEM
  * @param uuid      UUID
 */
+ (instancetype)apiWithPath:(NSString *)path RequestMethod:(NSString *)mothod UUID:(NSString *)uuid;
@end
