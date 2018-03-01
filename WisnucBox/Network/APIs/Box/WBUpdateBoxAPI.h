//
//  WBUpdateBoxAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/29.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBUpdateBoxAPI : JYBaseRequest
@property (nonatomic)NSArray *users;
@property (nonatomic)NSString *boxName;
@property (nonatomic)NSString *op;
@property (nonatomic)NSString *boxuuid;
/*
 * WISNUC API:UPDATE UPDATE A BOX USERS(DELETE,ADD)
 * @param boxuuid    Box UUID
 * @param users      ALL Users Array
 * @param op         Option
 */
+ (instancetype)updateApiWithBoxuuid:(NSString *)boxuuid Users:(NSArray *)users Option:(NSString *)op;
/*
 * WISNUC API:UPDATE A BOX NAME
 * @param boxuuid    Box UUID
 * @param boxName    box Name
 */
+ (instancetype)updateApiWithBoxName:(NSString *)boxName Boxuuid:(NSString *)boxuuid;
@end
