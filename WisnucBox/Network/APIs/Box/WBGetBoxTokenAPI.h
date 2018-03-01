//
//  WBGetBoxTokenAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
@property (nonatomic) NSString *guid;

@interface WBGetBoxTokenAPI : JYBaseRequest
/*
 * WISNUC API:GET BOX TOKEN
 * @param guid    GUID
 */
+ (instancetype)apiWithGuid:(NSString *)guid;

@end
