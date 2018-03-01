//
//  WBTweetAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/24.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBTweetAPI : JYBaseRequest
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSNumber *first;
@property (nonatomic) NSNumber *last;
@property (nonatomic) NSNumber *count;

/*
 * WISNUC API:GET TWEET LIST
 * @param boxuuid   Box UUID
 */
+ (instancetype)apiWithBoxuuid:(NSString *)boxuuid;

/*
 * WISNUC API:GET TWEET LIST(RANGE)
 * @param boxuuid   Box UUID
 * @param first     Frist Index
 * @param first     Last Index
 * @param count     Range Count
 */
+ (instancetype)apiWithBoxuuid:(NSString *)boxuuid First:(NSNumber *)first Last:(NSNumber *)last Count:(NSNumber *)count;
@end
