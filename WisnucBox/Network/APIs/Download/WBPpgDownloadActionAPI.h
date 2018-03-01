//
//  WBPpgDownloadActionAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBPpgDownloadActionAPI : JYBaseRequest
@property (nonatomic)NSString *ppgId;
@property (nonatomic)NSString *op;
/*
 * WISNUC API:/B/T/ DOWNLOAD STATUS ACTION
 * @param ppgId    M/a/g/n/e/t ID
 * @param op       Option(destroy,pause,resume)
 */
+ (instancetype)apiWithPpgId:(NSString *)ppgId Option:(NSString *)op;
@end
