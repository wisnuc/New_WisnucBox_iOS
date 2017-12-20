//
//  WBDownloadMagnetAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBDownloadMagnetAPI : JYBaseRequest
@property(nonatomic)NSString *dirUUID;
@property(nonatomic)NSString *magnetURL;
+ (instancetype)apiWithDirUUID:(NSString *)dirUUID MagnetURL:(NSString *)magnetURL;
@end
