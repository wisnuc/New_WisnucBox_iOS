//
//  WBUpgradeDownloadAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/28.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBUpgradeDownloadAPI : JYBaseRequest
@property (nonatomic) NSString *urlPath;
@property (nonatomic) NSString *tagName;
@property (nonatomic) NSString *state;
+ (instancetype)apiWithURLPath:(NSString *)urlPath  State:(NSString *)state TagName:(NSString *)tagName;
@end
