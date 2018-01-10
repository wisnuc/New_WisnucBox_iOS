//
//  WBPpgAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBPpgAPI : JYBaseRequest
@property(nonatomic)NSString *dirUUID;
@property(nonatomic)NSString *ppgURL;
+ (instancetype)apiWithDirUUID:(NSString *)dirUUID PpgURL:(NSString *)ppgURL;
@end
