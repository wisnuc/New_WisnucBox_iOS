//
//  WBReNameAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBReNameAPI : JYBaseRequest
@property (nonatomic) NSString * name;
/*
 * WISNUC API:UPDATE STATION NAME
 * @param name     New Station Name
 */
+ (instancetype)apiWithName:(NSString *)name;
@end
