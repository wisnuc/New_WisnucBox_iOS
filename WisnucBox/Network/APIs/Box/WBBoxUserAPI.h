//
//  WBBoxUserAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/2/8.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBBoxUserAPI : JYBaseRequest
@property (nonatomic) NSString *guid;
/*
 * WISNUC API:GET BOX ENABLE USERS (TO CREAT A BOX,USER ADD ,USER DELETE)
 * @param guid   GUID
 */
+ (instancetype)userApiWithGuid:(NSString *)guid;
@end
