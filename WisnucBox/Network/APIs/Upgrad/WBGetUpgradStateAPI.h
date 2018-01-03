//
//  WBGetUpgradStateAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetUpgradStateAPI : JYBaseRequest
+ (instancetype)apiWithURLPath:(NSString *)urlPath;
@property (nonatomic) NSString *urlPath;
@end
