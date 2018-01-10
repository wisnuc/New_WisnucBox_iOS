//
//  WBGetDownloadAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBGetDownloadAPI : JYBaseRequest
@property (nonatomic)NSString *type;
@property (nonatomic)NSString *ppgId;
+ (instancetype)apiWithType:(NSString *)type PpgId:(NSString *)ppgId;
@end
