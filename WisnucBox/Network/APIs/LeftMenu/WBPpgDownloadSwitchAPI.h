//
//  WBPpgDownloadSwitchAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:/B/T/ DOWNLOAD SERVICE SWITCH STATUS(no param)
 */
@interface WBPpgDownloadSwitchAPI : JYBaseRequest
@property(nonatomic)NSString *method;
@property(nonatomic)NSString *option;
/*
 * WISNUC API:/B/T/ DOWNLOAD SERVICE SWITCH
 * @param option    Option(start,close)
 */
+ (instancetype)apiWithRequestMethod:(NSString *)method Option:(NSString *)option;
@end
