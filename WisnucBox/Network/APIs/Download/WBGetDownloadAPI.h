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
/*
 * WISNUC API:/B/T/ DOWNLOAD STATUS
 * @param type   DOWNLOAD STATUS
 * @param ppgId    M/a/g/n/e/t ID
 * ALL DOWNLOAD STATUS(no param)
 */
+ (instancetype)apiWithType:(NSString *)type PpgId:(NSString *)ppgId;
@end
