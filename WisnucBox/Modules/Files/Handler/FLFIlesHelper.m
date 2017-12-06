//
//  FLFIlesHelper.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLFIlesHelper.h"
#import "LocalDownloadViewController.h"
#import "CSDownloadHelper.h"
#import "CSFileUtil.h"
#import "FilesNextViewController.h"
#import "WBFilesAndTransmitProtocal.h"

@interface FLFIlesHelper ()
{
     FilesServices *_filesServices;
}

@property (nonatomic) NSMutableArray * chooseFiles;
@property (nonatomic) NSMutableArray * chooseFilesUUID;


@end

@implementation FLFIlesHelper

static FLFIlesHelper * helper = nil;
static dispatch_once_t onceToken;

+ (instancetype)helper{
    dispatch_once(&onceToken, ^{
        helper = [FLFIlesHelper new];
    });
    return helper;
}

+ (void)destroyAll{
    onceToken = 0;
    helper = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
       _filesServices = [FilesServices new];
    }
    return self;
}

- (void)addChooseFile:(EntriesModel *)model{
    @synchronized (self) {
        //当没有选择过文件
        if(![self containsFile:model]){
            [self.chooseFiles addObject:model];
            [self.chooseFilesUUID addObject:model.uuid];
            if (self.chooseFiles.count == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(1)];
            }
        }
    }
}

- (void)removeChooseFile:(EntriesModel *)model{
    @synchronized (self) {
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (EntriesModel * file in self.chooseFiles) {
            if (IsEquallString(model.uuid, file.uuid)) {
                [tempArr  addObject:file];
            }
        }
        [self.chooseFiles removeObjectsInArray:tempArr];
        [self.chooseFilesUUID removeObject:model.uuid];
        if (self.chooseFiles.count == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(0)];
        }
    }
}

- (BOOL)containsFile:(EntriesModel *)model{
    return [self.chooseFilesUUID containsObject:model.uuid];
}


- (void)removeAllChooseFile{
    [self.chooseFiles removeAllObjects];
    [self.chooseFilesUUID removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(0)];
    
}

- (NSMutableArray *)chooseFiles{
    if (!_chooseFiles) {
        _chooseFiles = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseFiles;
}

- (NSMutableArray *)chooseFilesUUID{
    if(!_chooseFilesUUID){
        _chooseFilesUUID = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseFilesUUID;
}

- (void)downloadChooseFilesParentUUID:(NSString *)uuid RootUUID:(NSString *)rootUUID{
    for (EntriesModel * model in [FLFIlesHelper helper].chooseFiles) {
        if ([model.type isEqualToString:@"file"]) {
//            NSLog(@"%@",model.type);
            [[CSDownloadHelper shareManager] downloadFileWithFileModel:model RootUUID:rootUUID UUID:uuid];
        }
    }
     NSString * string  = [NSString stringWithFormat:@"%ld个文件已添加到下载队列",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    [SXLoadingView showProgressHUDText:string duration:1.5];
    [[FLFIlesHelper helper] removeAllChooseFile];
}

- (void)configCells:(FLFilesCell * )cell withModel:(EntriesModel *)model cellStatus:(FLFliesCellStatus)status viewController:(UIViewController *)viewController parentUUID:(NSString *)uuid RootUUID:(NSString *)rootUUID{
    cell.nameLabel.text = model.name;
    cell.sizeLabel.text = [NSString fileSizeWithFLModel:model];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([model.type isEqualToString:@"file"]) {
        BOOL resultPNG = [[model.name pathExtension] caseInsensitiveCompare:@"png"] == NSOrderedSame;
        BOOL resultGIF = [[model.name pathExtension] caseInsensitiveCompare:@"gif"] == NSOrderedSame;
        BOOL resultJPG = [[model.name pathExtension] caseInsensitiveCompare:@"jpg"] == NSOrderedSame;
        BOOL resultMP4 = [[model.name pathExtension] caseInsensitiveCompare:@"mp4"] == NSOrderedSame;
        BOOL resultMOV = [[model.name pathExtension] caseInsensitiveCompare:@"mov"] == NSOrderedSame;
        if (resultPNG) {
            cell.f_ImageView.image = [UIImage imageNamed:@"png_icon"];
        }else if (resultGIF){
            cell.f_ImageView.image = [UIImage imageNamed:@"gif_icon"];
        }else if (resultJPG){
            cell.f_ImageView.image = [UIImage imageNamed:@"jpg_icon"];
        }else if (resultMP4){
            cell.f_ImageView.image = [UIImage imageNamed:@"mp4_icon"];
        }else if (resultMOV){
            cell.f_ImageView.image = [UIImage imageNamed:@"mov_icon"];
        }else {
            cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
        }
//        cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
        cell.timeLabel.text = [self getTimeWithTimeSecond:model.mtime/1000];
    }else{
        cell.f_ImageView.image = [UIImage imageNamed:@"folder_icon"];
        cell.timeLabel.text = [self getTimeWithTimeSecond:model.mtime/1000];
        cell.sizeLabel.hidden = YES;
    }
    cell.downBtn.hidden = ((status == FLFliesCellStatusNormal)?![model.type isEqualToString:@"file"]:YES);
    if (status == FLFliesCellStatusNormal) {
        cell.downBtn.userInteractionEnabled = YES;
    }else{
         cell.downBtn.userInteractionEnabled = NO;
    }
    if ([self containsFile:model]) {
        cell.f_ImageView.hidden = YES;
        cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
    }else{
        if ([model.type isEqualToString:@"file"]) {
            cell.f_ImageView.hidden = NO;
            cell.layerView.image = [UIImage imageNamed:@"check_circle"];
        }
    }

    @weaky(self);
    if ([model.type isEqualToString:@"file"]) {
        NSString *redownloadString = WBLocalizedString(@"re_download_the_item", nil);
        cell.clickBlock = ^(FLFilesCell * cell){
            cell.downBtn.userInteractionEnabled = YES;
            weak_self.chooseModel = model;
            NSString *downloadString  =WBLocalizedString(@"download_the_item", nil);
            NSString *openFileString;
            NSMutableArray *downloadedArr = [NSMutableArray arrayWithArray:[_filesServices findAll]];
            for (WBFile * fileModel in downloadedArr) {
                if ([fileModel.fileUUID isEqualToString:model.uuid]) {
                    downloadString = redownloadString;
                    openFileString = WBLocalizedString(@"open_the_item", nil);
                }
            }

    
            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
            if (downloadString.length>0) {
                [arr addObject:downloadString];
            }
//
            if (openFileString.length>0) {
                [arr addObject:openFileString];
            }
            NSString *cancelTitle = WBLocalizedString(@"cancel", nil);
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:cancelTitle
                                                        otherButtonTitleArray:arr];
            actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                if (buttonIndex == 1) {
                if ([downloadString isEqualToString:redownloadString]) {
                    [_filesServices deleteFileWithFileUUID:model.uuid FileName:model.name ActionType:nil];
                }
                [[CSDownloadHelper  shareManager] downloadFileWithFileModel:model RootUUID:rootUUID UUID:uuid ];
                if(viewController){
	                LocalDownloadViewController * localVC = [[LocalDownloadViewController alloc] init];
	                [viewController.navigationController pushViewController:localVC animated:true];
                }
                }else if(buttonIndex == 2) {
                    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
//                    NSString* suffixName = model.uuid;
                    NSString *fileName = model.name;
//                    NSString *extensionstring = [fileName pathExtension];
                    NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
            
                    if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
                        if (_openFilesdelegate && [_openFilesdelegate respondsToSelector:@selector(openTheFileWithFilePath:)]) {
                            [_openFilesdelegate openTheFileWithFilePath:saveFile];
                        }
                    }
//                    if ([viewController isEqual:[FLFilesVC class]]) {
//                        [(FLFilesVC *)viewController shareFiles];
//                    }else{
//                        [(FLSecondFilesVC *)viewController shareFiles];
//                    }
                }
            };
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        };
    }
    
    cell.longpressBlock =^(FLFilesCell * cell){
        if (status == FLFliesCellStatusNormal) {
            if ([model.type isEqualToString:@"file"])
                [weak_self addChooseFile:model];
        }
    };
    
    cell.status = status;
}


-(NSString *)getTimeWithTimeSecond:(long long)second{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter * formater = [NSDateFormatter new];
    formater.dateFormat = @"yyyy年MM月dd日 hh:mm:ss";
    NSString * dateString = [formater stringFromDate:date];
    return dateString;
}


@end
