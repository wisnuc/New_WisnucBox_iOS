//
//  FLFIlesHelper.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FLFilesModel.h"
//#import "FLDownloadManager.h"
#import "FLFilesCell.h"
#import "LCActionSheet.h"
#import "TestDataModel.h"

#define FLFilesStatusChangeNotify @"FLFilesStatusChangeNotify"

@protocol FilesHelperOpenFilesDelegate <NSObject>

-(void)openTheFileWithFilePath:(NSString *)filePath;

@end

@interface FLFIlesHelper : NSObject
@property (nonatomic,weak) id<FilesHelperOpenFilesDelegate>openFilesdelegate;

@property (nonatomic,readonly) NSMutableArray * chooseFiles;

@property (nonatomic) TestDataModel * chooseModel;

+(instancetype)helper;

-(void)downloadChooseFilesParentUUID:(NSString *)uuid;

-(void)configCells:(FLFilesCell * )cell withModel:(TestDataModel *)model cellStatus:(FLFliesCellStatus)status viewController:(UIViewController *)viewController parentUUID:(NSString *)uuid;

-(void)addChooseFile:(TestDataModel *)model;

-(void)removeChooseFile:(TestDataModel *)model;

-(void)removeAllChooseFile;

-(void)cancleDownload;

//- (void)downloadAloneFilesWithModel:(TestDataModel *)model parentUUID:(NSString *)uuid Progress:(TYDownloadProgressBlock)progress State:(TYDownloadStateBlock)state;
//判断该文件是否已经被选择
-(BOOL)containsFile:(TestDataModel *)model;
@end
