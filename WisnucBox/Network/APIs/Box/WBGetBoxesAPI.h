//
//  WBGetBoxesAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/23.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetBoxesAPI : JYBaseRequest
@property (nonatomic)NSArray *users;
@property (nonatomic)NSString *boxName;
@property (nonatomic)NSString *op;
+ (instancetype)creatApiWithUsers:(NSArray *)users BoxName:(NSString *)boxName;
@end
