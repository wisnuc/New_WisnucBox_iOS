//
//  BootModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/12.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"

@interface BootModel : WBBaseModel
@property (nonatomic,copy) NSString *current;
@property (nonatomic,copy) NSString *state;
@property (nonatomic,copy) NSString *error;
@property (nonatomic,copy) NSString *mode;
@end
