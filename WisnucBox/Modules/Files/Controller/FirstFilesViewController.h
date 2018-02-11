//
//  FirstFilesViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//



#import "FMBaseFirstVC.h"
@class FirstFilesModel;

typedef NS_ENUM(NSInteger,WBFilesFirstDirectoryType) {
    WBFilesFirstDirectoryMyFiles,//默认从0开始
    WBFilesFirstDirectoryShare,
    WBFilesFirstDirectoryPublic
};

typedef NS_ENUM(NSInteger,WBFilesFirstSelectType) {
    WBFilesFirstBoxSelectType = 1,
    WBFilesFirstNormalType,
    WBFilesFirstBoxBrowseType
};

@interface FirstFilesViewController : FMBaseFirstVC
@property (nonatomic) WBFilesFirstSelectType selectType;
@end

@interface FirstFilesModel : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *uuid;
@property (nonatomic) WBFilesFirstDirectoryType type;

@end
