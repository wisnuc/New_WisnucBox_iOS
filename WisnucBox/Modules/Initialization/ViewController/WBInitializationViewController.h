//
//  WBInitializationViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/12.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FABaseVC.h"
#import "FMSerachService.h"

@interface WBInitializationViewController : FABaseVC
@property (nonatomic) FMSerachService *searchModel;
- (void)weChatCallBackRespCode:(NSString *)code;
@end
