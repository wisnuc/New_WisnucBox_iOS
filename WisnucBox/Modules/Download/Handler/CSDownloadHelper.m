//
//  CSDownloadHelper.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSDownloadHelper.h"
#import "CSFileUtil.h"
#import "LocalDownloadViewController.h"
#import "CSFilesOneDownloadManager.h"
#import "CSOneDowloadTask.h"

@interface CSDownloadHelper()<CSDownloadUIBindProtocol>
{
    CSFileDownloadManager* _manager;
    int _downdloadCount;
    NSMutableArray * _oneDownloadArray;
    CSFilesOneDownloadManager* _oneManager;
}
@end


@implementation CSDownloadHelper

- (void)dealloc{
    
}
static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;
+ (CSDownloadHelper *)shareManager
{
    dispatch_once(&p, ^{
        _sharedObject = [[CSDownloadHelper alloc] init];
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
        _manager = [CSFileDownloadManager sharedDownloadManager];
        _oneManager = [CSFilesOneDownloadManager shareManager];
        _manager.maxDownload = 3;
        _manager.maxWaiting = 3;
        _manager.maxPaused = 3;
        _manager.maxFailureRetryChance = 5;
        
        _downdloadCount = 0;
        
        _oneDownloadArray = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)downloadOneFileWithFileModel:(EntriesModel *)dataModel
                            RootUUID:(NSString *)rootUUID
                                UUID:(NSString *)uuid
                       IsDownloading:(HelperDownloadingEventHandler)isDownloading
                               begin:(CSDownloadBeginEventHandler)begin
                            progress:(CSDownloadingEventHandler)progress
                            complete:(CSOneDownloadedEventHandler)complete{
    
    NSString *resource = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries/%@",rootUUID,uuid,dataModel.uuid];
    
    NSString *loaclFormUrl = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/%@?name=%@",[JYRequestConfig sharedConfig].baseURL,rootUUID,uuid,dataModel.uuid,dataModel.name];
    
    NSString* fromUrl = WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET&name=%@", kCloudAddr, kCloudCommonPipeUrl, [resource base64EncodedString],dataModel.name] :loaclFormUrl;
    
//    NSLog(@"%@",fromUrl);
    NSString* suffixName = dataModel.name;
    NSDate* datenow = [NSDate date];
    NSString* tmpFileName = [NSString stringWithFormat:@"file-%@%@.tmp",suffixName,datenow];
    NSString* saveFileName= [NSString stringWithFormat:@"%@",dataModel.uuid];
    NSString *extensionstring = [suffixName pathExtension];
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:YES];
    NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",saveFileName,extensionstring]];
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
    [downloadFileModel setGetDownloadFileUUID:dataModel.uuid];
    [downloadFileModel setDownloadTaskURL:fromUrl];
    [downloadFileModel setDownloadFileSavePath:saveFile];
    [downloadFileModel setDownloadTempSavePath:tempFile];
    [downloadFileModel setDownloadFileUserId:WB_UserService.currentUser.uuid];
    [downloadFileModel setDownloadFilePlistURL:@""];
    NSNumber* fileSize = [NSNumber numberWithLongLong:dataModel.size];
    [downloadFileModel setDownloadFileSize:fileSize];
    
    CSOneDowloadTask* downloadTask = [[CSOneDowloadTask alloc] init];
    [downloadTask setDownloadTaskId:[NSString stringWithFormat:@"%d", _downdloadCount + 1]];
    [downloadTask setDownloadFileModel:downloadFileModel];
    [downloadTask setDownloadUIBinder:self];
    if(_manager.downloadingTasks.count>0){
        __block BOOL find = NO;
        [_manager.downloadingTasks enumerateObjectsUsingBlock:^(CSDownloadTask * obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@", downloadTask.downloadFileModel.getDownloadFileUUID);
            NSLog(@"%@",obj.downloadFileModel.getDownloadFileUUID);
            if([obj.downloadFileModel.getDownloadFileUUID  isEqualToString:downloadTask.downloadFileModel.getDownloadFileUUID]){
                * stop = YES;
                isDownloading(YES);
            }
        }];
        
        if (!find) {
            [_oneDownloadArray addObject:downloadTask];
            [self startOneDownloadWithTask:downloadTask begin:begin progress:progress complete:complete];
        }
     
    } else{
        
        [_oneDownloadArray addObject:downloadTask];
        [self startOneDownloadWithTask:downloadTask begin:begin progress:progress complete:complete];
    }
}

- (void)downloadFileWithFileModel:(EntriesModel *)dataModel RootUUID:(NSString *)rootUUID UUID:(NSString *)uuid{
    _downdloadCount++;
    NSString *resource = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries/%@",rootUUID,uuid,dataModel.uuid];
    
    NSString *loaclFormUrl = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/%@?name=%@",[JYRequestConfig sharedConfig].baseURL,rootUUID,uuid,dataModel.uuid,dataModel.name];
    
    NSString* fromUrl = WB_UserService.currentUser.isCloudLogin ? [NSString stringWithFormat:@"%@%@?resource=%@&method=GET&name=%@", kCloudAddr, kCloudCommonPipeUrl, [resource base64EncodedString],dataModel.name] :loaclFormUrl;;

    NSString* suffixName = dataModel.name;
    NSString* tmpFileName = [NSString stringWithFormat:@"file-%d.tmp",_downdloadCount];
    NSString* saveFileName= [NSString stringWithFormat:@"%@",dataModel.uuid];
    
    NSString *extensionstring = [suffixName pathExtension];
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:YES];
    NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",saveFileName,extensionstring]];
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
    [downloadFileModel setGetDownloadFileUUID:dataModel.uuid];
    [downloadFileModel setDownloadTaskURL:fromUrl];
    [downloadFileModel setDownloadFileSavePath:saveFile];
    [downloadFileModel setDownloadTempSavePath:tempFile];
    [downloadFileModel setDownloadFileUserId:WB_UserService.currentUser.uuid];
    [downloadFileModel setDownloadFilePlistURL:@""];
    NSNumber* fileSize = [NSNumber numberWithLongLong:dataModel.size];
    [downloadFileModel setDownloadFileSize:fileSize];
    
    CSDownloadTask* downloadTask = [[CSDownloadTask alloc] init];
    [downloadTask setDownloadTaskId:[NSString stringWithFormat:@"%d", _downdloadCount]];
    [downloadTask setDownloadFileModel:downloadFileModel];
    [downloadTask setDownloadUIBinder:self];

    if(_manager.downloadingTasks.count>0){
      __block BOOL find = NO;
    [_manager.downloadingTasks enumerateObjectsUsingBlock:^(CSDownloadTask * obj, NSUInteger idx, BOOL *stop) {
        if([obj.downloadFileModel.getDownloadFileUUID  isEqualToString:downloadTask.downloadFileModel.getDownloadFileUUID]){
            * stop = YES;
            find = YES;
        }
    }];
        if (!find) {
            [_manager addDownloadTask:downloadTask];
            [self startDownloadWithTask:downloadTask];
        }
      
    } else{
        [_manager addDownloadTask:downloadTask];
        [self startDownloadWithTask:downloadTask];
    }
}


- (void)startOneDownloadWithTask:(CSOneDowloadTask*)downloadTask begin:(CSDownloadBeginEventHandler)begin
                        progress:(CSDownloadingEventHandler)progress
                        complete:(CSOneDownloadedEventHandler)complete{
    
    
    CSFilesOneDownloadManager *oneManager = [CSFilesOneDownloadManager shareManager];

    [oneManager beginDownloadTask:downloadTask begin:begin  progress: progress complete:^(CSOneDowloadTask *csdownloadTask, NSError *error) {
        [_oneDownloadArray removeAllObjects];
        if (error)
        {
            NSLog(@"下载失败,%@",error);
            NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if(errorData.length >0){
                NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                NSLog(@"下载失败,%@",serializedData);
            }
//            downloadTask.downloadStatus = CSDownloadStatusFailure;
            [self updateUIWithTask:downloadTask];
            complete(csdownloadTask,error);
        }
        else
        {
            NSLog(@"下载成功");
//            downloadTask.downloadStatus = CSDownloadStatusSuccess;
            [self updateUIWithTask:downloadTask];
            complete(csdownloadTask,nil);
        }
    }];
//    [oneManager downloadDataAsyncWithTask:downloadTask
//                                  begin:begin
//                               progress:progress
//                               complete:^(CSDownloadTask *csdownloadTask,NSError *error) {
//                                   [_oneDownloadArray removeAllObjects];
//                                   if (error)
//                                   {
//                                       NSLog(@"下载失败,%@",error);
//                                       NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//                                       if(errorData.length >0){
//                                           NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//                                          NSLog(@"下载失败,%@",serializedData);
//                                       }
//                                       downloadTask.downloadStatus = CSDownloadStatusFailure;
//                                       [self updateUIWithTask:downloadTask];
//                                       complete(csdownloadTask,error);
//                                   }
//                                   else
//                                   {
//                                       NSLog(@"下载成功");
//                                       downloadTask.downloadStatus = CSDownloadStatusSuccess;
//                                       [self updateUIWithTask:downloadTask];
//                                       complete(csdownloadTask,nil);
//                                   }
//                               }];
}

- (void)startDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager downloadDataAsyncWithTask:downloadTask
                                  begin:^{
                                      [self updateUIWithTask:downloadTask];
                                      NSLog(@"准备开始下载...");
                                  }
                               progress:^(NSProgress *downloadProgress) {
//                                   downloadTask.totalBytesRead = totalBytesRead;
//                                   downloadTask.totalBytesExpectedToRead = totalBytesExpectedToRead;
//                                   downloadTask.progress = downloadProgress;
                                   //                                  dispatch_async(dispatch_get_main_queue(), ^{
                                   if (downloadTask.progressBlock) {
                                       downloadTask.progressBlock(downloadProgress);
                                   }
                                   //                                  });
                                   
                               }
                               complete:^(CSDownloadTask *csdownloadTask,NSError *error) {
                                   
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

- (void)startAllDownloadTask{
   [_manager startAllDownloadTask];
}

- (void)pauseAllDownloadTask{
    [_manager pauseAllDownloadTask];
}

- (void)pauseDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager pauseOneDownloadTaskWith:downloadTask];
}

- (void)continueDownloadWithTask:(CSDownloadTask*)downloadTask
{
    [_manager continueOneDownloadTaskWith:downloadTask];
}

- (void)cancleDownload{
    if (_oneDownloadArray.count>0) {
        [_oneDownloadArray enumerateObjectsUsingBlock:^(CSDownloadTask* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_oneManager cancelOneDownloadTaskWith:obj];
            [_oneDownloadArray removeAllObjects];
        }];
    }
}

- (void)updateUIWithTask:(id<CSSingleDownloadTaskProtocol>)downloadTask{
    CSDownloadTask *task = downloadTask;
    if ([_delegate respondsToSelector:@selector(updateDataWithDownloadTask:)]) { // 如果协议响应了sendValue:方法
        [_delegate updateDataWithDownloadTask:task]; // 通知执行协议方法
    }

}

@end
