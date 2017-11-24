//
//  CSFileDownloadManager.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSFileDownloadManager.h"
#import "CSDownloadTaskQueue.h"
#import "CSFileUtil.h"
#import "CSDateUtil.h"
#import "NSObject+KVOBlock.h"
#import "CSDownloadModel.h"
#import "FilesServices.h"
#import "CSDownloadHelper.h"

#define DEFAULT_QUEUE_CAPACITY 6        //默认队列容量
#define DEFAULT_FAITURE_RETRY_CHANCE 6  //默认失败重试机会
@interface CSFileDownloadManager ()

@end

@implementation CSFileDownloadManager
{
    /**
     *  下载任务列表
     */
    NSMutableArray* _downloadTasks;
    
    /**
     *  下载任务进行队列
     */
    CSDownloadTaskQueue* _taskDoingQueue;
    /**
     *  下载任务队列KVO观察者
     */
    id _taskDoingQueueKVO;
    
    /**
     *  下载任务等待队列
     */
    CSDownloadTaskQueue* _taskWaitingQueue;
    /**
     *  等待队列KVO观察者
     */
    id _taskWaitingQueueKVO;
    
    /**
     *  下载任务暂停队列
     */
    CSDownloadTaskQueue* _taskPausedQueue;
    /**
     *  暂停队列KVO观察者
     */
    id _taskPausedQueueKVO;
    
    //    pthread_mutex_t _mutex;
    
    RACSubject *_subject;
    
    NSInteger _excuteCount;
    
}

- (id)init
{
    self = [super init];
    if (self) {
   
        _downloadTasks = [NSMutableArray array];
        
        _maxDownload    = DEFAULT_QUEUE_CAPACITY;
        _maxWaiting     = DEFAULT_QUEUE_CAPACITY;
        _maxPaused      = DEFAULT_QUEUE_CAPACITY;
        
        _maxFailureRetryChance = DEFAULT_FAITURE_RETRY_CHANCE;
        
        _taskDoingQueue     = [[CSDownloadTaskQueue alloc] initWithMaxCapacity:_maxDownload];
        _taskWaitingQueue   = [[CSDownloadTaskQueue alloc] initWithMaxCapacity:_maxWaiting];
        _taskPausedQueue    = [[CSDownloadTaskQueue alloc] initWithMaxCapacity:_maxPaused];
        _subject = [RACSubject subject];
        _excuteCount = 0;
        //初始下载中队列容量变化观察
        [self initDownloadTaskDoingQueueObserver];
    }
    
    return  self;
}


static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;

+ (CSFileDownloadManager*)sharedDownloadManager
{

    dispatch_once(&p, ^{
        _sharedObject = [[CSFileDownloadManager alloc] init];
    });
    
    return _sharedObject;
}

+ (void)destroyAll{
    [[CSFileDownloadManager sharedDownloadManager] cancelAllDownloadTask];
     p = 0;
    _sharedObject = nil;
}

- (void)downloadDataAsyncWithTask:(CSDownloadTask*)downloadTask
                            begin:(CSDownloadBeginEventHandler)begin
                         progress:(CSDownloadingEventHandler)progress
                         complete:(CSDownloadedEventHandler)complete
{
    
    if ([_taskWaitingQueue full])
    {
        NSLog(@"等待队列满了，通知客户端达到下载最大限了");
        
        return;
    }
    
    [self beginDownloadTask:downloadTask begin:begin progress:progress complete:complete];
}

- (void)beginDownloadTask:(CSDownloadTask*)downloadTask
                    begin:(CSDownloadBeginEventHandler)begin
                 progress:(CSDownloadingEventHandler)progress
                 complete:(CSDownloadedEventHandler)complete
{
//  __block  NSFileHandle *fileHandel;
//    _excuteCount ++;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
   
    
    //获取文件模型数据
    __block CSDownloadModel* fileModel = [downloadTask getDownloadFileModel];
    
    if (![self validateFileMetaData:fileModel])
    {
        return;
    }
    
    if (begin)
    {
        [self.downloadingTasks addObject:downloadTask];
        begin();
    }
    
    BOOL isResuming = NO;
    
    NSString* dataUrl = [fileModel getDownloadTaskURL];
  
     NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[dataUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]]];
     [urlRequest setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    NSString* tempPath = [fileModel getDownloadTempSavePath];
    NSLog(@"临时下载地:%@",tempPath);
    //获取已下载文件大小，如果不为零，表示可以继续下载
    __block long long currentLength = [CSFileUtil fileSizeForPath:tempPath];
    __block long long fileLength;
    NSLog(@"已下载文件大小:%lld",currentLength);
    
    //断点续传
    if (currentLength > 0)
    {
        
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%zd-", currentLength];
        [urlRequest setValue:requestRange forHTTPHeaderField:@"Range"];
        
        isResuming = YES;
    }
    
   NSURLSessionDownloadTask * dataTask= [manager downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
        NSLog(@"%f",downloadProgress.fractionCompleted);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *path = [fileModel getDownloadFileSavePath];
        NSLog(@"%@",path);
        NSURL *url = [NSURL fileURLWithPath:path];
        return url;

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",error);
//         fileModel setDownloadFileSavePath:
        if (error) {
                    if (error.code == -1005) {
                        return ;
                    }
            [CSFileUtil deleteFileAtPath:[filePath absoluteString]];
                    [_taskDoingQueue dequeue];
                    [self.downloadingTasks removeObject:downloadTask];
                    int failureCount = [downloadTask increaseFailureCount];
                    NSString* tmpPath = [[downloadTask getDownloadFileModel] getDownloadTempSavePath];
        
                    NSLog(@"保存路径:%@,失败次数:%d,重试机会:%d",tmpPath,failureCount,self.maxFailureRetryChance);
        
                    if (failureCount <= self.maxFailureRetryChance)
                    {
                        NSLog(@"重试中...");
                        if (downloadTask.downloadStatus == CSDownloadStatusCanceled) {
                            //调用外部回调（比如执行UI更新），通知UI任务已经失败了
                            if (complete) {
                                complete(downloadTask,error);
                            }
                            return ;
                        }
                        //下载失败重新发起下载请求（即重试）
                        [self beginDownloadTask:downloadTask begin:begin progress:progress complete:complete];
                    }
                    else
                    {
                        NSLog(@"宣告失败...");
        
                        [downloadTask setDownloadStatus:CSDownloadStatusFailure];
                        [_downloadTasks removeObject:downloadTask];
                    }
            if (complete) {
                complete(downloadTask,nil);
            }
            
        }else{
            [downloadTask setDownloadStatus:CSDownloadStatusSuccess];
                        //从请求队列中移除
                        [_taskDoingQueue dequeue];
                        [self.downloadingTasks removeObject:downloadTask];
                        NSDate* curDate = [NSDate date];
            //            NSString* downloadFinishTime = [CSDateUtil stringWithDate:curDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
                        [fileModel setDownloadFinishTime:curDate];
            
                        //保存下载完成的文件信息
                        NSDictionary* downloadFinishInfo = @{
                                                             @"downloadFileName"       : [fileModel getDownloadFileName],
                                                             @"downloadFinishTime"     : [fileModel getDownloadFinishTime],
                                                             @"downloadFileSize"       : [fileModel getDownloadFileSize],
                                                             @"downloadFileSavePath"   : [fileModel getDownloadFileSavePath],
            
                                                             @"downloadFileUserId"    : [fileModel getDownloadFileUserId],
                                                             @"downloadFileFromURL"    : [fileModel getDownloadTaskURL],
                                                             @"downloadFilePlistURL"   : [fileModel getDownloadFilePlistURL]
                                                             };
            
                        NSString* finishPlist = [[fileModel getDownloadFileSavePath] stringByAppendingPathExtension:@"plist"];
                        if (![downloadFinishInfo writeToFile:finishPlist atomically:YES])
                        {
                            NSLog(@"%@写入失败",finishPlist);
                        }else{
                            NSLog(@"%@写入成功",finishPlist);
                        }
            
                        //将文件从临时目录内剪切到下载目录
//                        NSString* tempFile = [fileModel getDownloadTempSavePath];
//                        NSString* saveFile = [fileModel getDownloadFileSavePath];
//                        [CSFileUtil cutFileAtPath:tempFile toPath:saveFile];
            
                        //移除临时plist
                        NSString* tempFilePlist = [[fileModel getDownloadTempSavePath] stringByAppendingPathExtension:@"plist"];
                        [CSFileUtil deleteFileAtPath:tempFilePlist];
            
                        WBFile * wBFile = [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
                        wBFile.uuid = fileModel.downloadFileUserId;
                        NSLog(@"%@",fileModel.downloadFileSize);
            //            wBFile.fileUUID = file.fileUUID;
                        wBFile.fileName = fileModel.downloadFileName;
                        wBFile.fileSize = [NSString stringWithFormat:@"%@",fileModel.downloadFileSize];
                        wBFile.downloadedFileSize = [NSString stringWithFormat:@"%@",fileModel.downloadedFileSize];
                        wBFile.filePath = fileModel.downloadFileSavePath;
                        wBFile.fileUUID = fileModel.getDownloadFileUUID;
                        wBFile.timeDate = fileModel.downloadFinishTime;
                        wBFile.downloadURL = fileModel.downloadTaskURL;
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            //            FilesServices *services = [FilesServices new];
            //            [services saveFile:wBFile];
            
                        [self.downloadedTasks addObject:downloadTask];
            
                    if (complete) {
                        complete(downloadTask,error);
                    }
        }
    }];
//    [dataTask resume];
    [downloadTask setDownloadDataTask:dataTask];
    [self startOneDownloadTaskWith:downloadTask];
    
    
////    __weak typeof(self) weakSelf = self;
////    downloadTask.stream = [NSOutputStream outputStreamToFileAtPath:tempPath append:YES];
//    NSURLSessionDataTask * dataTask = [manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"%@",error);
////            [downloadTask.stream close];
////            downloadTask.stream = nil;
//            if (error.code == -1005) {
//                return ;
//            }
//            [fileHandel closeFile];
//            fileHandel = nil;
//            [_taskDoingQueue dequeue];
//            [self.downloadingTasks removeObject:downloadTask];
//            int failureCount = [downloadTask increaseFailureCount];
//            NSString* tmpPath = [[downloadTask getDownloadFileModel] getDownloadTempSavePath];
//
//            NSLog(@"保存路径:%@,失败次数:%d,重试机会:%d",tmpPath,failureCount,self.maxFailureRetryChance);
//
//            if (failureCount <= self.maxFailureRetryChance)
//            {
//                NSLog(@"重试中...");
//                if (downloadTask.downloadStatus == CSDownloadStatusCanceled) {
//                    //调用外部回调（比如执行UI更新），通知UI任务已经失败了
//                    if (complete) {
//                        complete(downloadTask,error);
//                    }
//                    return ;
//                }
//                //下载失败重新发起下载请求（即重试）
//                [self beginDownloadTask:downloadTask begin:begin progress:progress complete:complete];
//            }
//            else
//            {
//                NSLog(@"宣告失败...");
//
//                [downloadTask setDownloadStatus:CSDownloadStatusFailure];
//                [_downloadTasks removeObject:downloadTask];
//                //                [GSFileUtil deleteFileAtPath:tmpPath];
//                //调用外部回调（比如执行UI更新），通知UI任务已经失败了
//                if (complete) {
//                    complete(downloadTask,error);
//                }
//            }
//        }else{
//
//            // 清空长度
//            currentLength = 0;
//            fileLength = 0;
//
//            // 关闭fileHandle
////            [downloadTask.stream close];
////            downloadTask.stream = nil;
//
//            [fileHandel closeFile];
//            fileHandel = nil;
//            // 向沙盒写入数据
//
//            [downloadTask setDownloadStatus:CSDownloadStatusSuccess];
//            //从请求队列中移除
//            [_taskDoingQueue dequeue];
//            [self.downloadingTasks removeObject:downloadTask];
//            NSDate* curDate = [NSDate date];
////            NSString* downloadFinishTime = [CSDateUtil stringWithDate:curDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
//            [fileModel setDownloadFinishTime:curDate];
//
//            //保存下载完成的文件信息
//            NSDictionary* downloadFinishInfo = @{
//                                                 @"downloadFileName"       : [fileModel getDownloadFileName],
//                                                 @"downloadFinishTime"     : [fileModel getDownloadFinishTime],
//                                                 @"downloadFileSize"       : [fileModel getDownloadFileSize],
//                                                 @"downloadFileSavePath"   : [fileModel getDownloadFileSavePath],
//
//                                                 @"downloadFileUserId"    : [fileModel getDownloadFileUserId],
//                                                 @"downloadFileFromURL"    : [fileModel getDownloadTaskURL],
//                                                 @"downloadFilePlistURL"   : [fileModel getDownloadFilePlistURL]
//                                                 };
//
//            NSString* finishPlist = [[fileModel getDownloadFileSavePath] stringByAppendingPathExtension:@"plist"];
//            if (![downloadFinishInfo writeToFile:finishPlist atomically:YES])
//            {
//                NSLog(@"%@写入失败",finishPlist);
//            }else{
//                NSLog(@"%@写入成功",finishPlist);
//            }
//
//            //将文件从临时目录内剪切到下载目录
//            NSString* tempFile = [fileModel getDownloadTempSavePath];
//            NSString* saveFile = [fileModel getDownloadFileSavePath];
//            [CSFileUtil cutFileAtPath:tempFile toPath:saveFile];
//
//            //移除临时plist
//            NSString* tempFilePlist = [[fileModel getDownloadTempSavePath] stringByAppendingPathExtension:@"plist"];
//            [CSFileUtil deleteFileAtPath:tempFilePlist];
//
//            WBFile * wBFile = [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
//            wBFile.uuid = fileModel.downloadFileUserId;
//            NSLog(@"%@",fileModel.downloadFileSize);
////            wBFile.fileUUID = file.fileUUID;
//            wBFile.fileName = fileModel.downloadFileName;
//            wBFile.fileSize = [NSString stringWithFormat:@"%@",fileModel.downloadFileSize];
//            wBFile.downloadedFileSize = [NSString stringWithFormat:@"%@",fileModel.downloadedFileSize];
//            wBFile.filePath = fileModel.downloadFileSavePath;
//            wBFile.fileUUID = fileModel.getDownloadFileUUID;
//            wBFile.timeDate = fileModel.downloadFinishTime;
//            wBFile.downloadURL = fileModel.downloadTaskURL;
//            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
////            FilesServices *services = [FilesServices new];
////            [services saveFile:wBFile];
//
//            [self.downloadedTasks addObject:downloadTask];
//            //调用外部回调（比如执行UI更新）
//            if (complete) {
//                complete(downloadTask,nil);
//                [_downloadTasks removeObject:downloadTask];
//                NSLog(@"%@",_downloadTasks);
//            }
//        }
//
//    }];
//
//
//
//    [manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
////        NSLog(@"%@",manager);
//        fileLength = response.expectedContentLength + currentLength;
//        NSString *path = [fileModel getDownloadTempSavePath];
//        NSLog(@"%@",path);
//
//        // 创建一个空的文件到沙盒中
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//
//        if (![fileManager fileExistsAtPath:path]) {
//            // 如果没有下载文件的话，就创建一个文件。如果有下载文件的话，则不用重新创建(不然会覆盖掉之前的文件)
//            [fileManager createFileAtPath:path contents:nil attributes:nil];
//        }
//
//        // 创建文件句柄
//        fileHandel = [NSFileHandle fileHandleForWritingAtPath:path];
//
////        [downloadTask.stream open];
//        // 允许处理服务器的响应，才会继续接收服务器返回的数据
//        return NSURLSessionResponseAllow;
//    }];
//
//
//
//    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
//        // 拼接文件总长度
////        [downloadTask.stream write:data.bytes maxLength:data.length];
//        [fileHandel seekToEndOfFile];
//        [fileHandel writeData:data];
//        currentLength += data.length;
//
//        //保存已下载文件大小
//        [fileModel setDownloadedFileSize:[NSNumber numberWithLongLong:currentLength]];
//
//
//
//        NSDictionary* downloadTmpInfo = @{
//                                          @"downloadFileName"       : [fileModel getDownloadFileName],
//                                          @"downloadFileSize"       : [fileModel getDownloadFileSize],
//                                          @"downloadedFileSize"     : [fileModel getDownloadedFileSize],
//                                          @"downloadFileSavePath"   : [fileModel getDownloadFileSavePath],
//                                          @"downloadFileTempPath"   : [fileModel getDownloadTempSavePath],
//                                          @"downloadFileUserId"     : [fileModel getDownloadFileUserId]
//                                          };
//
//        NSString* tempFilePlist = [[fileModel getDownloadTempSavePath] stringByAppendingPathExtension:@"plist"];
//        if (![downloadTmpInfo writeToFile:tempFilePlist atomically:YES]) {
//            NSLog(@"%@写入失败",tempFilePlist);
//        }
//        //更新临时文件信息
//
//        if (progress) {
//            float downloadProgress;
//            if (WB_UserService.currentUser.isCloudLogin) {
//                downloadProgress = (float)currentLength/[downloadTask.downloadFileModel.downloadFileSize floatValue];
//                NSLog(@"%lld/%@",currentLength,downloadTask.downloadFileModel.downloadFileSize);
//                progress(currentLength,[downloadTask.downloadFileModel.downloadFileSize longLongValue],downloadProgress);
//            }else{
//                downloadProgress  = (float)currentLength/(float)fileLength;
//                NSLog(@"%lld/%lld",currentLength,fileLength);
//                progress(currentLength,fileLength,downloadProgress);
//            }
//        }
//    }];
//

////    if (_excuteCount>1) {
////        return;
////    }
////    [_subject subscribeNext:^(id  _Nullable x) {
////        NSLog(@"%@",x);
////        CSDownloadTask *task = x;
////        [self.downloadingTasks removeObject:task];
//
//        //        [task.stream close];
//        //        task.stream = nil;
//        //        [_taskDoingQueue dequeue];
//        //        [self.downloadingTasks removeObject:task];
//        ////        [downloadTask setDownloadStatus:CSDownloadStatusFailure];
//        ////        [_downloadTasks removeObject:task];
//        //        configuration = nil;
//        //        urlRequest = nil;
//        //        [task setDownloadDataTask:nil];
// //        manager = nil;
//        //        [task setDownloadStatus:CSDownloadStatusFailure];
////        NSLog(@"%@",manager);
//        //        manager = nil;
//        //        [dataTask cancel];
//        //        dataTask = nil;
////        [weakSelf beginDownloadTask:task begin:begin progress:progress complete:complete];
////        [[CSDownloadHelper shareManager] startDownloadWithTask:task];
////         [self.downloadingTasks removeObject:downloadTask];
////    }];
}


- (void)startOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    [downloadTask setDownloadStatus:CSDownloadStatusWaitingForStart];
    
    if ([_taskDoingQueue full]) //下载队列满了....进入等待队列
    {
        NSLog(@"下载队列满了....进入等待队列.downloadTask = %@",downloadTask);
        
        [_taskWaitingQueue enqueue:downloadTask];
        
    }
    else //将任务推入下载队列，并开启下载
    {
        [_taskDoingQueue enqueue:downloadTask];
        [downloadTask startDownloadTask:^(){
            [downloadTask setDownloadStatus:CSDownloadStatusDownloading];
        }];
    }
}

/**
 *  继续一项下载任务
 *
 *  @param downloadTask 要继续的任务
 */
- (void)doContinueOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    
    if ([_taskDoingQueue full]) //下载队列满了....进入等待队列
    {
        NSLog(@"下载队列满了....进入等待队列.downloadTask = %@",downloadTask);
        
        //将处于任务暂停状态的，改为等待回复状态
        if ([downloadTask getDownloadStatus] == CSDownloadStatusPaused)
        {
            [downloadTask setDownloadStatus:CSDownloadStatusWaitingForResume];
        }
        
        [_taskWaitingQueue enqueue:downloadTask];
        
    }
    else //将任务推入下载队列，并恢复下载
    {
        [_taskDoingQueue enqueue:downloadTask];
        //暂停的直接恢复
        NSLog(@"%u",[downloadTask getDownloadStatus]);
        if ([downloadTask getDownloadStatus] == CSDownloadStatusPaused)
        {
            [downloadTask continueDownloadTask:^(BOOL isComplete) {
                [downloadTask setDownloadStatus:CSDownloadStatusDownloading];
                if (isComplete) {
//                    [_subject sendNext:downloadTask];
                      [self.downloadingTasks removeObject:downloadTask];
                      [[CSDownloadHelper shareManager] startDownloadWithTask:downloadTask];
                }
            }];
        }
        //还未启动的需要启动
        else if([downloadTask getDownloadStatus] == CSDownloadStatusWaitingForStart)
        {
            [downloadTask startDownloadTask:^(){
//                [_subject sendNext:downloadTask];
                [downloadTask setDownloadStatus:CSDownloadStatusDownloading];
            }];
        }
    }
    
}

- (void)continueOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    //从暂停队列中移除掉
    [_taskPausedQueue remove:downloadTask];
    
    [self doContinueOneDownloadTaskWith:downloadTask];
    
}

/**
 *  暂停一项下载任务
 *
 *  @param downloadTask 要暂停的任务
 */
- (void)doPauseOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    if ([downloadTask getDownloadStatus] == CSDownloadStatusDownloading)
    {
        //暂停任务
        [downloadTask pauseDownloadTask:^(){
            [downloadTask setDownloadStatus:CSDownloadStatusPaused];
        }];
    }
    
    //推入暂停队列
    [_taskPausedQueue enqueue:downloadTask];
}

- (void)pauseOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    //从下载队列中移除
    [_taskDoingQueue remove:downloadTask];
    
    [self doPauseOneDownloadTaskWith:downloadTask];
}

- (void)doCancelOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    //取消任务
    [downloadTask cancelDownloadTask:^(){
        [downloadTask setDownloadStatus:CSDownloadStatusCanceled];
    }];
    
    CSDownloadModel* fileModel = [downloadTask getDownloadFileModel];
    
    //移除临时文件
    NSString* tempFile = [fileModel getDownloadTempSavePath];
    [CSFileUtil deleteFileAtPath:tempFile];
    
    //移除临时plist
    NSString* tempFilePlist = [[fileModel getDownloadTempSavePath] stringByAppendingPathExtension:@"plist"];
    [CSFileUtil deleteFileAtPath:tempFilePlist];
    
    
    [self.downloadingTasks removeObject:downloadTask];
    [_downloadTasks removeObject:downloadTask];
}

- (void)cancelOneDownloadTaskWith:(CSDownloadTask*)downloadTask
{
    [self doPauseOneDownloadTaskWith:downloadTask];
    
    //从下载队列中移除
    [_taskDoingQueue remove:downloadTask];
    //从等待队列中移除
    [_taskWaitingQueue remove:downloadTask];
    //从暂停队列中移除
    [_taskPausedQueue remove:downloadTask];
    
    [self doCancelOneDownloadTaskWith:downloadTask];
    
}

- (void)startAllDownloadTask
{
    int taskCount = [_taskPausedQueue queueCount];
       NSLog(@"%d",taskCount);
    for (int i = 0; i < taskCount; i++)
    {
        CSDownloadTask* downloadTask = [_taskPausedQueue peekAtIndex:i];
        
        [self doContinueOneDownloadTaskWith:downloadTask];
    }
    
    [_taskPausedQueue clearQueue];
}

- (void)pauseAllDownloadTask
{
    
    int doingTaskCount = [_taskDoingQueue queueCount];
//    NSLog(@"%d",doingTaskCount);
    for (int i = 0; i < doingTaskCount; i++)
    {
        CSDownloadTask* downloadTask = [_taskDoingQueue peekAtIndex:i];
        
        [self doPauseOneDownloadTaskWith:downloadTask];
    }
    [_taskDoingQueue clearQueue];
    
    int waitingTaskCount = [_taskWaitingQueue queueCount];
    for (int i = 0; i < waitingTaskCount; i++)
    {
        CSDownloadTask* downloadTask = [_taskWaitingQueue peekAtIndex:i];
        
        [self doPauseOneDownloadTaskWith:downloadTask];
    }
    [_taskWaitingQueue clearQueue];
}

- (void)cancelAllDownloadTask
{
    //取消前先暂停
    [self pauseAllDownloadTask];
    
    int pausedTaskCount = [_taskPausedQueue queueCount];
    for (int i = 0; i < pausedTaskCount; i++) {
        
        CSDownloadTask* downloadTask = [_taskPausedQueue peekAtIndex:i];
        
        [self doCancelOneDownloadTaskWith:downloadTask];
    }
    
    [_taskPausedQueue clearQueue];
    
}

- (void)testQueueKVO
{
    
    NSString* test = @"我是一个测试";
    
    _taskDoingQueue.maxCapacity = 100;
    
    [_taskDoingQueue enqueue:test];
    [_taskDoingQueue enqueue:test];
    
    [_taskDoingQueue dequeue];
    [_taskDoingQueue dequeue];
    
}

- (void)setMaxDownload:(int)maxDownload
{
    _maxDownload = maxDownload;
    _taskDoingQueue.maxCapacity = _maxDownload;
    
}

// add by zhenwei
-(void)addDownloadTask:(CSDownloadTask*)task
{
    [_downloadTasks addObject:task];
}

-(NSArray*)downloadTasks
{
    return _downloadTasks;
}
// end

- (void)setMaxWaiting:(int)maxWaiting
{
    _maxWaiting = maxWaiting;
    _taskWaitingQueue.maxCapacity = _maxWaiting;
}

- (void)setMaxPaused:(int)maxPaused
{
    _maxPaused = maxPaused;
    
    _taskPausedQueue.maxCapacity = _maxPaused;
}

#pragma mark - Utilies
/**
 *  初始化下载队列观察者
 *
 *  @param queue
 */
- (void)initDownloadTaskDoingQueueObserver
{
    __weak CSDownloadTaskQueue* weakWaitingQueue = _taskWaitingQueue;
    __weak CSDownloadTaskQueue* weakOperationQueue = _taskDoingQueue;
    
    _taskDoingQueueKVO = [_taskDoingQueue addKVOBlockForKeyPath:@"isFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        
        BOOL isFullOldValue = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
        BOOL isFullNewValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        
        NSLog(@"I see you changed value from \"%@\" to \"%@\" (下载队列)", isFullOldValue ? @"YES" : @"NO", isFullNewValue ? @"YES" : @"NO");
        
        if (isFullOldValue == isFullNewValue && isFullNewValue == YES) {
            return;
        }
        
        //只要下载队列不为空，就从下载等待队列中取出任务，进行下载
        if (isFullNewValue == NO)
        {
            
            CSDownloadTask* downloadTask = (id<CSSingleDownloadTaskProtocol>)[weakWaitingQueue dequeue];
            
            //开始下载任务
            if (downloadTask != nil) {
                
                [weakOperationQueue enqueue:downloadTask];
                
                if ([downloadTask getDownloadStatus] == CSDownloadStatusWaitingForStart) //开始下载
                {
                    [downloadTask startDownloadTask:^(){
                        [downloadTask setDownloadStatus:CSDownloadStatusDownloading];
                    }];
                }
                else if([downloadTask getDownloadStatus] == CSDownloadStatusWaitingForResume) //恢复下载
                {
                    [downloadTask continueDownloadTask:^(BOOL isComplete){
                        [downloadTask setDownloadStatus:CSDownloadStatusDownloading];
                    }];
                }
            }
            else
            {
                NSLog(@"下载等待队列为空....");
            }
            
        }
        
        
    }];
}

/**
 *  验证下载文件元数据是否都合法
 *
 *  @param fileModel
 *
 *  @return
 */
- (BOOL)validateFileMetaData:(CSDownloadModel*)fileModel
{
    // TODO
    return YES;
}


- (NSMutableArray *)downloadedTasks{
    if (!_downloadedTasks) {
        _downloadedTasks = [NSMutableArray arrayWithCapacity:0];
    }
    return _downloadedTasks;
}

- (NSMutableArray *)downloadingTasks{
    if (!_downloadingTasks) {
        _downloadingTasks = [NSMutableArray arrayWithCapacity:0];
    }
    return _downloadingTasks;
}

#pragma mark - dealloc
- (void)dealloc
{
    [_taskDoingQueue removeKVOBlockForToken:_taskDoingQueueKVO];
}

@end

