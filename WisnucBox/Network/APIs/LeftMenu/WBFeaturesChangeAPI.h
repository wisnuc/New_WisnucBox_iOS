//
//  WBFeaturesChangeAPI.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/22.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WBFeaturesChangeAPI : JYBaseRequest
@property(nonatomic)NSString *type;
@property(nonatomic)NSString *action;
/*
 * WISNUC API:FEATURES SERVICES STATUS SWITCH
 * @param type    Service Type(samba,dlna)
 * @param action    Switch Action(start,stop)
 */
+ (instancetype)apiWithType:(NSString *)type Action:(NSString *)action;
@end
