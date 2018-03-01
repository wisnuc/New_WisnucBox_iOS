//
//  WBGetOneBoxAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/30.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetOneBoxAPI : JYBaseRequest
@property (nonatomic)NSString *boxuuid;
/*
 * WISNUC API:GET A BOX DATA
 * @param boxuuid    Box UUID
 */
+ (instancetype)getBoxApiWithBoxuuid:(NSString *)boxuuid;
@end
