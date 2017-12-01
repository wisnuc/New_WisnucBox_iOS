//
//  CSUploadHelper.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSUploadHelper.h"
#import "CSFileUtil.h"
#import "LocalDownloadViewController.h"

@interface CSUploadHelper()<CSUploadUIBindProtocol>
{
    CSFileUploadManager* _manager;
    int _uploadIdCount;
}
@property (nonatomic,strong) NSMutableArray *needUploadArray;
@end

@implementation CSUploadHelper


static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;
+ (CSUploadHelper *)shareManager
{
    dispatch_once(&p, ^{
        _sharedObject = [[CSUploadHelper alloc] init];
    });
    
    return _sharedObject;
}

+ (void)destroyAll{
    p = 0;
    _sharedObject = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [CSFileUploadManager sharedUploadManager];
        _manager.maxFailureRetryChance = 5;
        _uploadIdCount = 0;
    }
    return self;
}



- (void)readyUploadFilesWithFilePath:(NSString *)filePath{
    @weaky(self);
    if (!WB_UserService.currentUser.uploadFileDir) {
    [WB_NetService getUserBackupDirName:BackUpFilesDirName BackupDir:^(NSError *error, NSString *entryUUID) {
        if(error){
            [SXLoadingView showProgressHUDText:@"上传失败" duration:1.0];
            return ;
        }
        WB_UserService.currentUser.uploadFileDir = entryUUID;
        [weak_self uploadFileWithFilePath:filePath];
    }];
    }else{
        [weak_self uploadFileWithFilePath:filePath];
    }
}

- (void)uploadFileWithFilePath:(NSString *)filePath{
    _uploadIdCount++;
    NSString* suffixName = [filePath lastPathComponent];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        [SXLoadingView showProgressHUDText:@"该文件不存在" duration:1.0];
        return;
    }
    
    NSLog(@"上传文件路径为:%@",filePath);
    
    CSUploadModel* uploadFileModel = [[CSUploadModel alloc] init];
    [uploadFileModel setUploadFileName:[NSString stringWithFormat:@"%@",suffixName]];
    [uploadFileModel setUploadFileSavePath:filePath];
    [uploadFileModel setUploadFileUserId:WB_UserService.currentUser.uuid];
    NSNumber* fileSize = [NSNumber numberWithLongLong:[[manager attributesOfItemAtPath:filePath error:nil]fileSize]];
    [uploadFileModel setUploadFileSize:fileSize];
    
    CSUploadTask* uploadTask = [[CSUploadTask alloc] init];
    [uploadTask setUploadTaskId:[NSString stringWithFormat:@"%d", _uploadIdCount]];
    [uploadTask setUploadFileModel:uploadFileModel];
    [uploadTask setUploadUIBinder:self];
    
    if(_manager.uploadingTasks.count>0){
        __block BOOL find = NO;
        [_manager.uploadingTasks enumerateObjectsUsingBlock:^(CSUploadTask * obj, NSUInteger idx, BOOL *stop) {
            if([obj.uploadFileModel.getUploadFileName  isEqualToString:uploadTask.uploadFileModel.getUploadFileName]){
                * stop = YES;
                find = YES;
            }
        }];
        if (!find) {
            [_manager addUploadTask:uploadTask];
            [self startUploadWithTask:uploadTask];
        }
        
    } else{
        [_manager addUploadTask:uploadTask];
        [self startUploadWithTask:uploadTask];
    }
}


- (void)startUploadWithTask:(CSUploadTask*)uploadTask
{
    @weaky(self);
    [_manager uploadDataAsyncWithTask:uploadTask
                                  begin:^{
                                      [self updateUIWithTask:uploadTask];
                                      NSLog(@"准备开始上传...");
                                  }
                               progress:^(NSProgress *uploadProgress) {
                                   if (uploadTask.progressBlock) {
                                       uploadTask.progressBlock(uploadProgress);
                                   }
                                   //                                  });
                                   
                               }
                               complete:^(CSUploadTask *csuploadTask,NSError *error) {
                                   
                                   if (error)
                                   {
                                       NSLog(@"上传失败,%@",error);
                                       uploadTask.uploadStatus = CSUploadStatusFailure;
                                       [self updateUIWithTask:uploadTask];
                                   }
                                   else
                                   {
                                       NSLog(@"上传成功");
                                       uploadTask.uploadStatus = CSUploadStatusSuccess;
                                       [self updateUIWithTask:uploadTask];
                                       if (self.needUploadArray.count >0) {
                                           [self startUploadAction];
                                       }
                                   }
                                   
                               }];
    
}


- (void)startAllUploadTask{
    [_manager startAllUploadTask];
}

- (void)pauseAllUpTask{
    [_manager pauseAllUploadTask];
}

- (void)pauseUploadWithTask:(CSUploadTask*)uploadTask
{
    [_manager pauseOneUploadTaskWith:uploadTask];
}

- (void)continueUploadWithTask:(CSUploadTask*)uploadTask
{
    [_manager continueOneUploadTaskWith:uploadTask];
}


- (void)updateUIWithTask:(id<CSUploadTaskProtocol>)uploadTask{
    CSUploadTask *task = uploadTask;
    if ([_delegate respondsToSelector:@selector(updateDataWithUploadTask:)]) { // 如果协议响应了sendValue:方法
        [_delegate updateDataWithUploadTask:task]; // 通知执行协议方法
    }
    
}

- (void)startUploadAction{
    @weaky(self);
    [self getAllNeedUploadFiles];
    if (self.needUploadArray.count>0) {
        [_needUploadArray enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
            [weak_self uploadFileWithFilePath:filePath];
        }];
    }
}

- (void)getAllNeedUploadFiles{
    [self.needUploadArray removeAllObjects];
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:KUploadFilesDocument createIfNotExist:YES];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:savePath];
    for (NSString *fileName in enumerator)
    {
       NSString* saveFile = [savePath stringByAppendingPathComponent:fileName];
       [self.needUploadArray addObject:saveFile];
    }
}


- (NSMutableArray *)needUploadArray{
    if (!_needUploadArray) {
        _needUploadArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _needUploadArray;
}


@end
