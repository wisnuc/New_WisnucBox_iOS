//
//  WBGetBoxesAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:GET BOX LIST(no parameter)
 */
@interface WBGetBoxesAPI : JYBaseRequest
@property (nonatomic)NSArray *users;
@property (nonatomic)NSString *boxName;
@property (nonatomic)NSString *op;
/*
 * WISNUC API:CREAT A BOX WITH USERS AND BOX NAME
 * @param users    All Users Array
 * @param boxName    Box Name
 */
+ (instancetype)creatApiWithUsers:(NSArray *)users BoxName:(NSString *)boxName;
@end
