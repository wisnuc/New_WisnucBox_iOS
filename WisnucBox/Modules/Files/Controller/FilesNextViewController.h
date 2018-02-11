//
//  FilesNextViewController.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FABaseVC.h"
#import "FirstFilesViewController.h"
#import "WBTweetModel.h"

@interface FilesNextViewController : FABaseVC
@property (nonatomic) NSString * parentUUID;
@property (nonatomic) NSString * driveUUID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong)WBTweetModel *tweetModel;
@property (nonatomic) WBFilesFirstSelectType selectType;
@end
