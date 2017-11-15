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

@property (nonatomic) EntriesModel * chooseModel;

+(instancetype)helper;

-(void)downloadChooseFilesParentUUID:(NSString *)uuid;

-(void)configCells:(FLFilesCell * )cell withModel:(EntriesModel *)model cellStatus:(FLFliesCellStatus)status viewController:(UIViewController *)viewController parentUUID:(NSString *)uuid;

-(void)addChooseFile:(EntriesModel *)model;

-(void)removeChooseFile:(EntriesModel *)model;

-(void)removeAllChooseFile;

//判断该文件是否已经被选择
-(BOOL)containsFile:(EntriesModel *)model;
@end
