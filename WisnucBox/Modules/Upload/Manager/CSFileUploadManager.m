//
//  CSFileUploadManager.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSFileUploadManager.h"
#import "CSUploadTaskQueue.h"
#import "CSFileUtil.h"
#import "CSDateUtil.h"
#import "NSObject+KVOBlock.h"
#import "CSUploadModel.h"
#import "FilesServices.h"
#import "CSUploadEvenHandler.h"

#define DEFAULT_QUEUE_CAPACITY NSIntegerMax        //默认队列容量
#define DEFAULT_FAITURE_RETRY_CHANCE 6  //默认失败重试机会
@interface CSFileUploadManager ()

@end

@implementation CSFileUploadManager
{
    /**
     *  上传任务列表
     */
    NSMutableArray* _uploadTasks;
    
    /**
     *  上传任务进行队列
     */
    CSUploadTaskQueue* _taskDoingQueue;
    /**
     *  上传任务队列KVO观察者
     */
    id _taskDoingQueueKVO;
    
    /**
     *  上传任务等待队列
     */
    CSUploadTaskQueue* _taskWaitingQueue;
    /**
     *  等待队列KVO观察者
     */
    id _taskWaitingQueueKVO;
    
    /**
     *  上传任务暂停队列
     */
    CSUploadTaskQueue* _taskPausedQueue;
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
        
        _uploadTasks = [NSMutableArray array];
        
        _maxUpload    = DEFAULT_QUEUE_CAPACITY;
        _maxWaiting     = DEFAULT_QUEUE_CAPACITY;
        _maxPaused      = DEFAULT_QUEUE_CAPACITY;
        
        _maxFailureRetryChance = DEFAULT_FAITURE_RETRY_CHANCE;
        
        _taskDoingQueue     = [[CSUploadTaskQueue alloc] initWithMaxCapacity:_maxUpload];
        _taskWaitingQueue   = [[CSUploadTaskQueue alloc] initWithMaxCapacity:_maxWaiting];
        _taskPausedQueue    = [[CSUploadTaskQueue alloc] initWithMaxCapacity:_maxPaused];
        _subject = [RACSubject subject];
        _excuteCount = 0;
        //初始上传中队列容量变化观察
        [self initUploadTaskDoingQueueObserver];
    }
    
    return  self;
}


static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;

+ (CSFileUploadManager*)sharedUploadManager
{
    
    dispatch_once(&p, ^{
        _sharedObject = [[CSFileUploadManager alloc] init];
    });
    
    return _sharedObject;
}

+ (void)destroyAll{
    [[CSFileUploadManager sharedUploadManager] cancelAllUploadTask];
    p = 0;
    _sharedObject = nil;
}

- (void)uploadDataAsyncWithTask:(CSUploadTask*)uploadTask
                            begin:(CSUploadBeginEventHandler)begin
                         progress:(CSUploadingEventHandler)progress
                         complete:(CSUploadedEventHandler)complete
{
    
    if ([_taskWaitingQueue full])
    {
        NSLog(@"等待队列满了，通知客户端达到上传最大限了");
        
        return;
    }
    
    [self beginUploadTask:uploadTask begin:begin progress:progress complete:complete];
}

- (void)beginUploadTask:(CSUploadTask*)uploadTask
                    begin:(CSUploadBeginEventHandler)begin
                 progress:(CSUploadingEventHandler)progress
                 complete:(CSUploadedEventHandler)complete
{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //获取文件模型数据
    __block CSUploadModel* fileModel = [uploadTask getUploadFileModel];
    
    if (![self validateFileMetaData:fileModel])
    {
        return;
    }
    
    if (begin)
    {
        [self.uploadingTasks addObject:uploadTask];
        begin();
    }
    NSString * filePath = fileModel.uploadTempSavePath;
    NSString * hashString  = [FileHash sha256HashOfFileAtPath:filePath];
    NSNumber * sizeNumber = [NSNumber numberWithLongLong:[WB_FileService fileSizeAtPath:filePath]];
    NSString * fileName = [filePath lastPathComponent];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString;
    NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (WB_UserService.currentUser.isCloudLogin) {
        urlString = [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonPipeUrl];
        NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries", WB_UserService.currentUser.userHome,   WB_UserService.currentUser.uploadFileDir];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
        [manifestDic setObject:@"newfile" forKey:kCloudBodyOp];
        [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
        [manifestDic setObject:fileName forKey:kCloudBodyToName];
        [manifestDic setObject:resource forKey:kCloudBodyResource];
        [manifestDic setObject:hashString forKey:@"sha256"];
        [manifestDic setObject:sizeNumber forKey:@"size"];
        NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
        [mutableDic setObject:result forKey:@"manifest"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
        manager.requestSerializer.timeoutInterval = 200000;
    }else {
        urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,WB_UserService.currentUser.userHome, WB_UserService.currentUser.uploadFileDir];
        mutableDic = nil;
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    }
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if(WB_UserService.currentUser.isCloudLogin) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"image/jpeg" error:nil];
        }else {
            NSDictionary *dic = @{@"size":sizeNumber,@"sha256":hashString};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString =  [[NSString alloc] initWithData:jsonData  encoding:NSUTF8StringEncoding];
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:jsonString mimeType:@"image/jpeg" error:nil];
        }
    }
                         progress:progress
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              NSLog(@"Upload Success -->");
                              NSLog(@"%@",responseObject);
                             
                                          [uploadTask setUploadStatus:CSUploadStatusSuccess];
                                          [_taskDoingQueue dequeue];
                                          [self.uploadingTasks removeObject:uploadTask];
                                          NSDate* curDate = [NSDate date];
                                          [fileModel setUploadFinishTime:curDate];
                              
                                          NSString* tempFile = [fileModel getUploadTempSavePath];
                                          NSString* saveFile = [fileModel getUploadFileSavePath];
                                          NSFileManager *manager = [NSFileManager defaultManager];
                                          if ([manager fileExistsAtPath:tempFile]) {
                                            [CSFileUtil cutFileAtPath:tempFile toPath:saveFile];
                                          }
                                         [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                          WBFile * wBFile = [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
                                          wBFile.uuid = fileModel.uploadFileUserId;
                                          NSLog(@"%@",fileModel.uploadFileSize);
                                          NSDate* datenow = [NSDate date];
                                          wBFile.fileUUID = [NSString stringWithFormat:@"%@%@",hashString,datenow];
                                          wBFile.fileName = fileModel.uploadFileName;
                                          wBFile.fileSize = [NSString stringWithFormat:@"%@",fileModel.uploadFileSize];
                                          wBFile.filePath = fileModel.uploadFileSavePath;
                                          wBFile.timeDate = fileModel.uploadFinishTime;
                                          wBFile.actionType = @"上传";
                                          [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                          //            FilesServices *services = [FilesServices new];
                                          //            [services saveFile:wBFile];
                              
                                          [self.uploadedTasks addObject:uploadTask];
                              
                                          if (complete) {
                                              complete(uploadTask,nil);
                                          }
                                      }
                
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              NSLog(@"Upload Failure ---> : %@", error);
                              NSLog(@"Upload Failure ---> : %@  ----> : %ld", fileName, (long)((NSHTTPURLResponse *)task.response).statusCode);
                              NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                              if(errorData.length >0){
                                  NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                                  NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
                                  if([serializedData isKindOfClass:[NSArray class]]) {
                                      @try {
                                          NSDictionary *errorRootDic = serializedData[0];
                                          NSDictionary *errorDic = errorRootDic[@"error"];
                                          NSString *code = errorDic[@"code"];
                                          NSInteger status = [errorDic[@"status"] integerValue];
                                          if ([code isEqualToString:@"EEXIST"])
                                              error.wbCode = WBUploadFileExist;
                                          if(status == 404)
                                              error.wbCode = WBUploadDirNotFound;
                                      } @catch (NSException *exception) {
                                          NSLog(@"%@", exception);
                                      }
                                  }
                              }
                              
                              [_taskDoingQueue dequeue];
                              [self.uploadingTasks removeObject:uploadTask];
//                              int failureCount = [uploadTask increaseFailureCount];
//
//
//                                          NSLog(@"路径:%@,失败次数:%d,重试机会:%d",filePath,failureCount,self.maxFailureRetryChance);
//
//                                          if (failureCount <= self.maxFailureRetryChance)
//                                          {
//                                              NSLog(@"重试中...");
//                                              if (uploadTask.uploadStatus == CSUploadStatusCanceled) {
//                                                  //调用外部回调（比如执行UI更新），通知UI任务已经失败了
//                                                  if (complete) {
//                                                      complete(uploadTask,error);
//                                                  }
//                                                  return ;
//                                              }
//                                              //上传失败重新发起上传请求（即重试）
//                                              [self beginUploadTask:uploadTask begin:begin progress:progress complete:complete];
//                                          }
//                                          else
//                                          {
                                              NSLog(@"宣告失败...");
                              
                                              [uploadTask setUploadStatus:CSUploadStatusFailure];
                                              [_uploadTasks removeObject:uploadTask];
        
//                                          }
                                          if (complete) {
                                              complete(uploadTask,error);
                                          }
                          }];
        [uploadTask setUploadDataTask:dataTask];
        [self startOneUploadTaskWith:uploadTask];
    
    
//
//    BOOL isResuming = NO;
//
//    NSString* dataUrl = [fileModel getUploadTaskURL];
//
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[dataUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]]];
//    [urlRequest setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
//    NSString* tempPath = [fileModel getUploadTempSavePath];
//    NSLog(@"临时上传地:%@",tempPath);
//    //获取已上传文件大小，如果不为零，表示可以继续上传
//    __block long long currentLength = [CSFileUtil fileSizeForPath:tempPath];
//    __block long long fileLength;
//    NSLog(@"已上传文件大小:%lld",currentLength);
//
//    //断点续传
//    if (currentLength > 0)
//    {
//
//        NSString *requestRange = [NSString stringWithFormat:@"bytes=%zd-", currentLength];
//        [urlRequest setValue:requestRange forHTTPHeaderField:@"Range"];
//
//        isResuming = YES;
//    }
//
//    NSURLSessionUploadTask * dataTask= [manager UploadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull UploadProgress) {
//        if (progress) {
//            progress(UploadProgress);
//        }
//        NSLog(@"%lld",UploadProgress.completedUnitCount);
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        NSString *path = [fileModel getUploadFileSavePath];
//        NSLog(@"%@",path);
//        NSURL *url = [NSURL fileURLWithPath:path];
//        return url;
//
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        NSLog(@"%@",error);
//        //         fileModel setUploadFileSavePath:
//        if (error) {
//            if (error.code == -1005) {
//                return ;
//            }
//            [CSFileUtil deleteFileAtPath:[filePath absoluteString]];
//            [_taskDoingQueue dequeue];
//            [self.UploadingTasks removeObject:UploadTask];
//            int failureCount = [UploadTask increaseFailureCount];
//            NSString* tmpPath = [[UploadTask getUploadFileModel] getUploadTempSavePath];
//
//            NSLog(@"保存路径:%@,失败次数:%d,重试机会:%d",tmpPath,failureCount,self.maxFailureRetryChance);
//
//            if (failureCount <= self.maxFailureRetryChance)
//            {
//                NSLog(@"重试中...");
//                if (UploadTask.UploadStatus == CSUploadStatusCanceled) {
//                    //调用外部回调（比如执行UI更新），通知UI任务已经失败了
//                    if (complete) {
//                        complete(UploadTask,error);
//                    }
//                    return ;
//                }
//                //上传失败重新发起上传请求（即重试）
//                [self beginUploadTask:UploadTask begin:begin progress:progress complete:complete];
//            }
//            else
//            {
//                NSLog(@"宣告失败...");
//
//                [UploadTask setUploadStatus:CSUploadStatusFailure];
//                [_UploadTasks removeObject:UploadTask];
//            }
//            if (complete) {
//                complete(UploadTask,nil);
//            }
//
//        }else{
//            [UploadTask setUploadStatus:CSUploadStatusSuccess];
//            //从请求队列中移除
//            [_taskDoingQueue dequeue];
//            [self.UploadingTasks removeObject:UploadTask];
//            NSDate* curDate = [NSDate date];
//            //            NSString* UploadFinishTime = [CSDateUtil stringWithDate:curDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
//            [fileModel setUploadFinishTime:curDate];
//
//            //保存上传完成的文件信息
//            NSDictionary* UploadFinishInfo = @{
//                                                 @"UploadFileName"       : [fileModel getUploadFileName],
//                                                 @"UploadFinishTime"     : [fileModel getUploadFinishTime],
//                                                 @"UploadFileSize"       : [fileModel getUploadFileSize],
//                                                 @"UploadFileSavePath"   : [fileModel getUploadFileSavePath],
//
//                                                 @"UploadFileUserId"    : [fileModel getUploadFileUserId],
//                                                 @"UploadFileFromURL"    : [fileModel getUploadTaskURL],
//                                                 @"UploadFilePlistURL"   : [fileModel getUploadFilePlistURL]
//                                                 };
//
//            NSString* finishPlist = [[fileModel getUploadFileSavePath] stringByAppendingPathExtension:@"plist"];
//            if (![UploadFinishInfo writeToFile:finishPlist atomically:YES])
//            {
//                NSLog(@"%@写入失败",finishPlist);
//            }else{
//                NSLog(@"%@写入成功",finishPlist);
//            }
//
//            //将文件从临时目录内剪切到上传目录
//            //                        NSString* tempFile = [fileModel getUploadTempSavePath];
//            //                        NSString* saveFile = [fileModel getUploadFileSavePath];
//            //                        [CSFileUtil cutFileAtPath:tempFile toPath:saveFile];
//
//            //移除临时plist
//            NSString* tempFilePlist = [[fileModel getUploadTempSavePath] stringByAppendingPathExtension:@"plist"];
//            [CSFileUtil deleteFileAtPath:tempFilePlist];
//
//            WBFile * wBFile = [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
//            wBFile.uuid = fileModel.UploadFileUserId;
//            NSLog(@"%@",fileModel.UploadFileSize);
//            //            wBFile.fileUUID = file.fileUUID;
//            wBFile.fileName = fileModel.UploadFileName;
//            wBFile.fileSize = [NSString stringWithFormat:@"%@",fileModel.UploadFileSize];
//            wBFile.UploadedFileSize = [NSString stringWithFormat:@"%@",fileModel.UploadedFileSize];
//            wBFile.filePath = fileModel.UploadFileSavePath;
//            wBFile.fileUUID = fileModel.getUploadFileUUID;
//            wBFile.timeDate = fileModel.UploadFinishTime;
//            wBFile.UploadURL = fileModel.UploadTaskURL;
//            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//            //            FilesServices *services = [FilesServices new];
//            //            [services saveFile:wBFile];
//
//            [self.UploadedTasks addObject:UploadTask];
//
//            if (complete) {
//                complete(UploadTask,error);
//            }
//        }
//    }];
//
//    if (WB_UserService.currentUser.isCloudLogin) {
//        __block  NSProgress *UploadProgress = [[NSProgress alloc]init];
//        [manager setUploadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionUploadTask * _Nonnull UploadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//            NSLog(@"%lld/%lld/%lld",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
//            UploadProgress.completedUnitCount = totalBytesWritten;
//            UploadProgress.totalUnitCount = [fileModel.getUploadFileSize longLongValue];
//            if (progress && UploadProgress) {
//                progress(UploadProgress);
//            }
//        }];
//    }
//
//    [UploadTask setUploadDataTask:dataTask];
//    [self startOneUploadTaskWith:UploadTask];

}


- (void)startOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    [uploadTask setUploadStatus:CSUploadStatusWaitingForStart];
    
    if ([_taskDoingQueue full]) //上传队列满了....进入等待队列
    {
        NSLog(@"上传队列满了....进入等待队列.UploadTask = %@",uploadTask);
        
        [_taskWaitingQueue enqueue:uploadTask];
        
    }
    else //将任务推入上传队列，并开启上传
    {
        [_taskDoingQueue enqueue:uploadTask];
        [uploadTask startUploadTask:^(){
            [uploadTask setUploadStatus:CSUploadStatusUploading];
        }];
    }
}

/**
 *  继续一项上传任务
 *
 *  @param UploadTask 要继续的任务
 */
- (void)doContinueOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    
    if ([_taskDoingQueue full]) //上传队列满了....进入等待队列
    {
        NSLog(@"上传队列满了....进入等待队列.UploadTask = %@",uploadTask);
        
        //将处于任务暂停状态的，改为等待回复状态
        if ([uploadTask getUploadStatus] == CSUploadStatusPaused)
        {
            [uploadTask setUploadStatus:CSUploadStatusWaitingForResume];
        }
        
        [_taskWaitingQueue enqueue:uploadTask];
        
    }
    else //将任务推入上传队列，并恢复上传
    {
        [_taskDoingQueue enqueue:uploadTask];
        //暂停的直接恢复
        NSLog(@"%u",[uploadTask getUploadStatus]);
        if ([uploadTask getUploadStatus] == CSUploadStatusPaused)
        {
            [uploadTask continueUploadTask:^() {
                [uploadTask setUploadStatus:CSUploadStatusUploading];
            }];
        }
        //还未启动的需要启动
        else if([uploadTask getUploadStatus] == CSUploadStatusWaitingForStart)
        {
            [uploadTask startUploadTask:^(){
                //                [_subject sendNext:UploadTask];
                [uploadTask setUploadStatus:CSUploadStatusUploading];
            }];
        }
    }
    
}

- (void)continueOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    //从暂停队列中移除掉
    [_taskPausedQueue remove:uploadTask];
    
    [self doContinueOneUploadTaskWith:uploadTask];
    
}

/**
 *  暂停一项上传任务
 *
 *  @param UploadTask 要暂停的任务
 */
- (void)doPauseOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    if ([uploadTask getUploadStatus] == CSUploadStatusUploading)
    {
        //暂停任务
        [uploadTask pauseUploadTask:^(){
            [uploadTask setUploadStatus:CSUploadStatusPaused];
        }];
    }
    
    //推入暂停队列
    [_taskPausedQueue enqueue:uploadTask];
}

- (void)pauseOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    //从上传队列中移除
    [_taskDoingQueue remove:uploadTask];
    
    [self doPauseOneUploadTaskWith:uploadTask];
}

- (void)doCancelOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    //取消任务
    [uploadTask cancelUploadTask:^(){
        [uploadTask setUploadStatus:CSUploadStatusCanceled];
    }];
    
//    CSUploadModel* fileModel = [UploadTask getUploadFileModel];
    
    [self.uploadingTasks removeObject:uploadTask];
    [_uploadTasks removeObject:uploadTask];
    NSError *error;
//    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:KUploadFilesDocument createIfNotExist:NO];
//    NSString* saveFile = [savePath stringByAppendingPathComponent:uploadTask.getUploadFileModel.uploadFileName];
    [[NSFileManager defaultManager] removeItemAtPath:uploadTask.getUploadFileModel.uploadFileSavePath error:&error];
    if (!error) {
        NSLog(@"删除文件成功");
    }else{
        NSLog(@"删除文件失败");
    }
}

- (void)cancelOneUploadTaskWith:(CSUploadTask*)uploadTask
{
    [self doPauseOneUploadTaskWith:uploadTask];
    
    //从上传队列中移除
    [_taskDoingQueue remove:uploadTask];
    //从等待队列中移除
    [_taskWaitingQueue remove:uploadTask];
    //从暂停队列中移除
    [_taskPausedQueue remove:uploadTask];
    
    [self doCancelOneUploadTaskWith:uploadTask];
    
}

- (void)startAllUploadTask
{
    int taskCount = [_taskPausedQueue queueCount];
    NSLog(@"%d",taskCount);
    for (int i = 0; i < taskCount; i++)
    {
        CSUploadTask* uploadTask = [_taskPausedQueue peekAtIndex:i];
        
        [self doContinueOneUploadTaskWith:uploadTask];
    }
    
    [_taskPausedQueue clearQueue];
}

- (void)pauseAllUploadTask
{
    
    int doingTaskCount = [_taskDoingQueue queueCount];
    //    NSLog(@"%d",doingTaskCount);
    for (int i = 0; i < doingTaskCount; i++)
    {
        CSUploadTask* uploadTask = [_taskDoingQueue peekAtIndex:i];
        
        [self doPauseOneUploadTaskWith:uploadTask];
    }
    [_taskDoingQueue clearQueue];
    
    int waitingTaskCount = [_taskWaitingQueue queueCount];
    for (int i = 0; i < waitingTaskCount; i++)
    {
        CSUploadTask* uploadTask = [_taskWaitingQueue peekAtIndex:i];
        
        [self doPauseOneUploadTaskWith:uploadTask];
    }
    [_taskWaitingQueue clearQueue];
}

- (void)cancelAllUploadTask
{
    //取消前先暂停
    [self pauseAllUploadTask];
    
    int pausedTaskCount = [_taskPausedQueue queueCount];
    for (int i = 0; i < pausedTaskCount; i++) {
        
        CSUploadTask* uploadTask = [_taskPausedQueue peekAtIndex:i];
        
        [self doCancelOneUploadTaskWith:uploadTask];
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

- (void)setMaxUpload:(int)maxUpload
{
    _maxUpload = maxUpload;
    _taskDoingQueue.maxCapacity = _maxUpload;
    
}

// add by zhenwei
-(void)addUploadTask:(CSUploadTask*)task
{
    [_uploadTasks addObject:task];
}

-(NSArray*)uploadTasks
{
    return _uploadTasks;
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
 *  初始化上传队列观察者
 *
 *  @param queue
 */
- (void)initUploadTaskDoingQueueObserver
{
    __weak CSUploadTaskQueue* weakWaitingQueue = _taskWaitingQueue;
    __weak CSUploadTaskQueue* weakOperationQueue = _taskDoingQueue;
    
    _taskDoingQueueKVO = [_taskDoingQueue addKVOBlockForKeyPath:@"isFull" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        
        BOOL isFullOldValue = [[change objectForKey:NSKeyValueChangeOldKey] boolValue];
        BOOL isFullNewValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        
        NSLog(@"I see you changed value from \"%@\" to \"%@\" (上传队列)", isFullOldValue ? @"YES" : @"NO", isFullNewValue ? @"YES" : @"NO");
        
        if (isFullOldValue == isFullNewValue && isFullNewValue == YES) {
            return;
        }
        
        //只要上传队列不为空，就从上传等待队列中取出任务，进行上传
        if (isFullNewValue == NO)
        {
            
            CSUploadTask* uploadTask = (id<CSUploadTaskProtocol>)[weakWaitingQueue dequeue];
            
            //开始上传任务
            if (uploadTask != nil) {
                
                [weakOperationQueue enqueue:uploadTask];
                
                if ([uploadTask getUploadStatus] == CSUploadStatusWaitingForStart) //开始上传
                {
                    [uploadTask startUploadTask:^(){
                        [uploadTask setUploadStatus:CSUploadStatusUploading];
                    }];
                }
                else if([uploadTask getUploadStatus] == CSUploadStatusWaitingForResume) //恢复上传
                {
                    [uploadTask continueUploadTask:^(){
                        [uploadTask setUploadStatus:CSUploadStatusUploading];
                    }];
                }
            }
            else
            {
                NSLog(@"上传等待队列为空....");
            }
            
        }
        
        
    }];
}

/**
 *  验证上传文件元数据是否都合法
 *
 *  @param fileModel
 *
 *  @return
 */
- (BOOL)validateFileMetaData:(CSUploadModel*)fileModel
{
    // TODO
    return YES;
}


- (NSMutableArray *)uploadedTasks{
    if (!_uploadedTasks) {
        _uploadedTasks = [NSMutableArray arrayWithCapacity:0];
    }
    return _uploadedTasks;
}

- (NSMutableArray *)uploadingTasks{
    if (!_uploadingTasks) {
        _uploadingTasks = [NSMutableArray arrayWithCapacity:0];
    }
    return _uploadingTasks;
}

#pragma mark - dealloc
- (void)dealloc
{
    [_taskDoingQueue removeKVOBlockForToken:_taskDoingQueueKVO];
}

@end


