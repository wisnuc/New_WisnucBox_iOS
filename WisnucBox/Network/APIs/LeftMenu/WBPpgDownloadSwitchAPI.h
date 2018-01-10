//
//  WBPpgDownloadSwitchAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBPpgDownloadSwitchAPI : JYBaseRequest
@property(nonatomic)NSString *method;
@property(nonatomic)NSString *option;
+ (instancetype)apiWithRequestMethod:(NSString *)method Option:(NSString *)option;
@end
