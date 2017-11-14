//
//  CSDownloadHelper.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSDownloadHelper.h"
#import "CSFileDownloadManager.h"
#import "CSFileUtil.h"

@interface CSDownloadHelper()<CSDownloadUIBindProtocol>
{
    CSFileDownloadManager* _manager;
    int _downdloadCount;
    
}
@end


@implementation CSDownloadHelper

- (void)dealloc{
    
}

+ (CSDownloadHelper *)shareManager
{
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[CSDownloadHelper alloc] init];
    });
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [CSFileDownloadManager sharedDownloadManager];
        _manager.maxDownload = 3;
        _manager.maxWaiting = 3;
        _manager.maxPaused = 3;
        _manager.maxFailureRetryChance = 5;
        
        _downdloadCount = 0;
    }
    return self;
}



- (void)downloadFileWithFileModel:(TestDataModel *)dataModel UUID:(NSString *)uuid{
    _downdloadCount++;
    NSString* fromUrl = dataModel.URLstring;
    
    NSString* suffixName = [fromUrl lastPathComponent];
    NSString* tmpFileName = [NSString stringWithFormat:@"file-%d.tmp",_downdloadCount];
    NSString* saveFileName= [NSString stringWithFormat:@"%@",suffixName];
    
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:YES];
    NSString* saveFile = [savePath stringByAppendingPathComponent:saveFileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:saveFile]) {
        [SXLoadingView showProgressHUDText:@"该文件已下载" duration:1.0];
        return;
    }
    
    NSLog(@"成功下载路径为:%@",savePath);
    NSLog(@"成功文件为:%@",saveFile);
    
    NSString* tempPath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/Tmp" createIfNotExist:YES];
    NSString* tempFile = [tempPath stringByAppendingPathComponent:tmpFileName];
    
    NSLog(@"临时下载路径为:%@",tempPath);
    NSLog(@"临时文件为:%@",tempFile);
    
    //     NSString* fileName = [suffixName stringByDeletingPathExtension];
    
    CSDownloadModel* downloadFileModel = [[CSDownloadModel alloc] init];
    [downloadFileModel setDownloadFileName:[NSString stringWithFormat:@"%@",suffixName]];
    [downloadFileModel setGetDownloadFileUUID:dataModel.fileUUID];
    [downloadFileModel setDownloadTaskURL:fromUrl];
    [downloadFileModel setDownloadFileSavePath:saveFile];
    [downloadFileModel setDownloadTempSavePath:tempFile];
    [downloadFileModel setDownloadFileUserId:uuid];
    [downloadFileModel setDownloadFilePlistURL:@""];
    
    CSDownloadTask* downloadTask = [[CSDownloadTask alloc] init];
    [downloadTask setDownloadTaskId:[NSString stringWithFormat:@"%d", _downdloadCount]];
    [downloadTask setDownloadFileModel:downloadFileModel];
    [downloadTask setDownloadUIBinder:self];
    
    [_manager addDownloadTask:downloadTask];
    [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"已有%d个文件加入下载队列",_downdloadCount] duration:1.0];
    [self startDownloadWithTask:downloadTask];
}

- (void)addDownload
{
    NSLog(@"添加下载...");
    
    
}

- (void)startDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager downloadDataAsyncWithTask:downloadTask
                                  begin:^{
                                      
                                      NSLog(@"准备开始下载...");
                                  }
                               progress:^(long long totalBytesRead, long long totalBytesExpectedToRead, float progress) {
                                   downloadTask.totalBytesRead = totalBytesRead;
                                   downloadTask.totalBytesExpectedToRead = totalBytesExpectedToRead;
                                   downloadTask.progress = progress;
                                   //                                  dispatch_async(dispatch_get_main_queue(), ^{
                                   if (downloadTask.progressBlock) {
                                       downloadTask.progressBlock(totalBytesRead, totalBytesExpectedToRead, progress);
                                   }
                                   //                                  });
                                   
                               }
                               complete:^(NSError *error) {
                                   
                                   if (error)
                                   {
                                       NSLog(@"下载失败,%@",error);
                                       downloadTask.downloadStatus = CSDownloadStatusFailure;
                                       [self updateUIWithTask:downloadTask];
                                   }
                                   else
                                   {
                                       NSLog(@"下载成功");
                                       downloadTask.downloadStatus = CSDownloadStatusSuccess;
                                       [self updateUIWithTask:downloadTask];
                                   }
                                   
                               }];
    
}

- (void)pauseDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager pauseOneDownloadTaskWith:downloadTask];
}

- (void)continueDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager continueOneDownloadTaskWith:downloadTask];
}

- (void)updateUIWithTask:(id<CSSingleDownloadTaskProtocol>)downloadTask{
    CSDownloadTask *task = downloadTask;
    if ([_delegate respondsToSelector:@selector(updateDataWithDownloadTask:)]) { // 如果协议响应了sendValue:方法
        [_delegate updateDataWithDownloadTask:task]; // 通知执行协议方法
    }
}
@end
