//
//  FMUserEditVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FABaseVC.h"

@interface TicketModel : NSObject
@property (nonatomic,copy)NSString *ticketId;
@end

@interface FMUserEditVC : FABaseVC
- (void)weChatCallBackRespCode:(NSString *)code;
@end
