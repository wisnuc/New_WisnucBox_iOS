//
//  CSFilesOneDownloadManager.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSFilesOneDownloadManager.h"
@interface CSFilesOneDownloadManager ()

@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, strong) NSMutableArray *souceArray;
@end

@implementation CSFilesOneDownloadManager
static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;
+ (CSFilesOneDownloadManager*)shareManager
{
    
    dispatch_once(&p, ^{
        _sharedObject = [[CSFilesOneDownloadManager alloc] init];
    });
    
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)destroyAll{
    [[CSFilesOneDownloadManager shareManager] cancelAllDownloadTask];
    p = 0;
    _sharedObject = nil;
}

- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

- (void)beginDownloadTask:(CSOneDowloadTask*)downloadTask
                    begin:(CSDownloadBeginEventHandler)begin
                 progress:(CSDownloadingEventHandler)progress
                 complete:(CSOneDownloadedEventHandler)complete{
    CSDownloadModel* fileModel = [downloadTask getDownloadFileModel];
    if (![self validateFileMetaData:fileModel])
    {
        return;
    }
    
    if (begin)
    {
        
        begin();
    }
    
    //    BOOL isResuming = NO;
    
    NSString* dataUrl = [fileModel getDownloadTaskURL];
    
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[dataUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]]];
    [urlRequest setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@", WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    NSString* tempPath = [fileModel getDownloadTempSavePath];
    NSLog(@"临时下载地:%@",tempPath);
    NSLog(@"%@", urlRequest.URL) ;
    //获取已下载文件大小，如果不为零，表示可以继续下载
//    __block long long currentLength = [CSFileUtil fileSizeForPath:tempPath];
    __block long long fileLength;
//    NSLog(@"已下载文件大小:%lld",currentLength);
    
    //断点续传
    //    if (currentLength > 0)
    //    {
    //
    //        NSString *requestRange = [NSString stringWithFormat:@"bytes=%zd-", currentLength];
    //        [urlRequest setValue:requestRange forHTTPHeaderField:@"Range"];
    //
    //        isResuming = YES;
    //    }
    
    
    NSURLSessionDownloadTask * dataTask= [self.manager downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
        NSLog(@"%f",downloadProgress.fractionCompleted);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
       
        NSString *path = [fileModel getDownloadFileSavePath];

        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"%@",filePath);
        if (error) {
            NSLog(@"%@",error);
            
            NSLog(@"宣告失败...");
            
            [downloadTask setDownloadStatus:CSDownloadStatusFailure];
            if (self.souceArray.count>0) {
                [self.souceArray removeObject:downloadTask];
            }
            
            //                [GSFileUtil deleteFileAtPath:tmpPath];
            //调用外部回调（比如执行UI更新），通知UI任务已经失败了
            if (complete) {
                complete(downloadTask,error);
            }
        }else{
            
            
            [downloadTask setDownloadStatus:CSDownloadStatusSuccess];
            //从请求队列中移除
            
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
            [self.souceArray removeObject:downloadTask];
            //调用外部回调（比如执行UI更新）
            if (complete) {
                complete(downloadTask,nil);
                
            }
        }
        
    }];
    [dataTask resume];
    [downloadTask setDownloadDataTask:dataTask];
    [self.souceArray addObject:downloadTask];
    NSLog(@"%@",self.souceArray);
    //    downloadTask.stream = [NSOutputStream outputStreamToFileAtPath:tempPath append:YES];
    //    NSURLSessionDataTask * dataTask = [self.manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    //        if (error) {
    //            NSLog(@"%@",error);
    //            [downloadTask.stream close];
    //            downloadTask.stream = nil;
    //                NSLog(@"宣告失败...");
    //
    //                [downloadTask setDownloadStatus:CSDownloadStatusFailure];
    //                [_souceArray removeObject:downloadTask];
    //                //                [GSFileUtil deleteFileAtPath:tmpPath];
    //                //调用外部回调（比如执行UI更新），通知UI任务已经失败了
    //                if (complete) {
    //                    complete(downloadTask,error);
    //                }
    ////            }
    //        }else{
    //
    //            // 清空长度
    //            currentLength = 0;
    //            fileLength = 0;
    //
    //            // 关闭fileHandle
    //            [downloadTask.stream close];
    //            downloadTask.stream = nil;
    //            [downloadTask setDownloadStatus:CSDownloadStatusSuccess];
    //            //从请求队列中移除
    //
    //            NSDate* curDate = [NSDate date];
    //            //            NSString* downloadFinishTime = [CSDateUtil stringWithDate:curDate withFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    //            //            wBFile.fileUUID = file.fileUUID;
    //            wBFile.fileName = fileModel.downloadFileName;
    //            wBFile.fileSize = [NSString stringWithFormat:@"%@",fileModel.downloadFileSize];
    //            wBFile.downloadedFileSize = [NSString stringWithFormat:@"%@",fileModel.downloadedFileSize];
    //            wBFile.filePath = fileModel.downloadFileSavePath;
    //            wBFile.fileUUID = fileModel.getDownloadFileUUID;
    //            wBFile.timeDate = fileModel.downloadFinishTime;
    //            wBFile.downloadURL = fileModel.downloadTaskURL;
    //            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    //            [_souceArray removeObject:downloadTask];
    //            //调用外部回调（比如执行UI更新）
    //            if (complete) {
    //                complete(downloadTask,nil);
    //
    //            }
    //        }
    //
    //    }];
    //
    //
    //
    //    [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
    //        NSLog(@"%@",dataTask);
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
    //
    //        [downloadTask.stream open];
    //        // 允许处理服务器的响应，才会继续接收服务器返回的数据
    //        return NSURLSessionResponseAllow;
    //    }];
    //
    //    [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
    //
    //        // 拼接文件总长度
    //        [downloadTask.stream write:data.bytes maxLength:data.length];
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
    
    
}

- (void)cancelOneDownloadTaskWith:(CSDownloadTask*)downloadTask{
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
    
}

- (void)cancelAllDownloadTask{
    @weaky(self)
    NSLog(@"%@",self.souceArray);
    [self.souceArray enumerateObjectsUsingBlock:^(CSDownloadTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weak_self cancelOneDownloadTaskWith:obj];
    }];
    [self.souceArray removeAllObjects];
}
- (NSMutableArray *)souceArray{
    if (!_souceArray) {
        _souceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _souceArray;
}
- (BOOL)validateFileMetaData:(CSDownloadModel*)fileModel
{
    // TODO
    return YES;
}
@end

