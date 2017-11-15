//
//  FilesModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBBaseModel.h"
#import "EntriesModel.h"

@interface FilesModel : WBBaseModel

@property (nonatomic) NSArray *entries;
@property (nonatomic) NSArray *path;

@end

