//
//  FilesShareViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/21.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FABaseVC.h"
@class ShareFilesModel;
@interface FilesShareViewController : FABaseVC
@property (nonatomic,strong) NSMutableArray *dataSouceArray;
@end

@interface ShareFilesModel : NSObject

@property (nonatomic,copy) NSString *owner;
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic,copy) NSString *tag;
@property (nonatomic,copy) NSArray *writelist;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *label;
@end
