//
//  FMUpdateUserAPI.h
//  WisnucBox
//
//  Created by 杨勇 on 2017/11/29.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYBaseRequest.h"
/*
 * WISNUC API:UPDATE USER NAME
 * @param userName    UserName
 */
@interface FMUpdateUserAPI : JYBaseRequest

@property (nonatomic) NSString * userName;

@end
