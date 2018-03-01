//
//  WBGetUpgradStateAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetUpgradStateAPI : JYBaseRequest
@property (nonatomic) NSString *urlPath;
/*
 * WISNUC API:  GET FIRMWARE UPDATE INFO
 * @param urlPath    URL
 */
+ (instancetype)apiWithURLPath:(NSString *)urlPath;
@end
