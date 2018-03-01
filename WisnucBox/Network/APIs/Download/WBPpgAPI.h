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
/*
 * WISNUC API:M/A/G/N/E/T DOWNLOAD
 * @param dirUUID   Directory UUID
 * @param ppgURL    M/a/g/n/e/t URL
 */
+ (instancetype)apiWithDirUUID:(NSString *)dirUUID PpgURL:(NSString *)ppgURL;
@end
