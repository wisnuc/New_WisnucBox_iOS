//
//  WBChatViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/16.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "FABaseVC.h"
#import "WBBoxesModel.h"

@interface WBChatViewController : FABaseVC
@property (nonatomic) WBBoxesModel *boxModel;
@end

@interface WBBoxMessageModel:NSObject
@property (nonatomic,copy)NSString *op;
@property (nonatomic)NSArray *value;
@end
