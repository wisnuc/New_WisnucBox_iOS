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
            [SXLoadingView showProgressHUDText:WBLocalizedString(@"upload_failed", nil) duration:1.0];
            return ;
        }else{
            [weak_self readyUploadFilesWithFilePath:filePath];
        }
        WB_UserService.currentUser.uploadFileDir = entryUUID;
        [WB_UserService synchronizedCurrentUser];
        [weak_self uploadFileWithFilePath:filePath];
    }];
    }else{
        [weak_self uploadFileWithFilePath:filePath];
    }
}

- (void)readyUploadPpgFilesWithFilePath:(NSString *)filePath DirUUID:(NSString *)dirUUID Complete:(void (^)(BOOL isComplete))complete{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString * hashString  = [FileHash sha256HashOfFileAtPath:filePath];
    NSNumber * sizeNumber = [NSNumber numberWithLongLong:[WB_FileService fileSizeAtPath:filePath]];
    NSString * fileName = [filePath lastPathComponent];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString;
    NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (WB_UserService.currentUser.isCloudLogin) {
        urlString = [NSString stringWithFormat:@"%@%@", kCloudAddr, kCloudCommonPipeUrl];
        NSString *requestUrl = [NSString stringWithFormat:@"download/ppg2"];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
        [manifestDic setObject:dirUUID forKey:@"dirUUID"];
        [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
        [manifestDic setObject:resource forKey:kCloudBodyResource];
        [manifestDic setObject:hashString forKey:@"sha256"];
        [manifestDic setObject:sizeNumber forKey:@"size"];
        NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
        [mutableDic setObject:result forKey:@"manifest"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
        manager.requestSerializer.timeoutInterval = 200000;
    }else {
        urlString = [NSString stringWithFormat:@"%@download/ppg2",[JYRequestConfig sharedConfig].baseURL];

        [mutableDic setObject:dirUUID forKey:@"dirUUID"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    }
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:mutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if(WB_UserService.currentUser.isCloudLogin) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName fileName:fileName mimeType:@"application/octet-stream" error:nil];
        }else {
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:filePath]) {
                NSLog(@"😁");
            }
            
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"ppg" fileName:fileName mimeType:@"application/octet-stream" error:nil];
        }
    }
                                          progress:^(NSProgress * _Nonnull uploadProgress) {
                                              
                                          }
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                               NSLog(@"Upload Success -->");
                                               NSLog(@"%@",responseObject);
                                               NSFileManager *manager = [NSFileManager defaultManager];
                                               if ([manager fileExistsAtPath:filePath]) {
                                                  [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                               }
                                               complete(YES);
                                           }
                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                               NSLog(@"Upload Failure ---> : %@", error);
                                               NSLog(@"Upload Failure ---> : %@  ----> : %ld", fileName, (long)((NSHTTPURLResponse *)task.response).statusCode);
                                               NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                                               if(errorData.length >0){
                                                   NSMutableArray *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                                                   NSLog(@"Upload Failure ---> :serializedData %@", serializedData);
                                                   
                                                   }
                                           }];
    [dataTask resume];
}

- (void)uploadFileWithFilePath:(NSString *)filePath{
    _uploadIdCount++;
    NSString* suffixName = [filePath lastPathComponent];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) {
        [SXLoadingView showProgressHUDText:WBLocalizedString(@"this_file_does_not_exist", nil) duration:1.0];
        return;
    }
    
    NSLog(@"上传文件路径为:%@",filePath);
    
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:YES];
    NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",suffixName]];
    
    CSUploadModel* uploadFileModel = [[CSUploadModel alloc] init];
    [uploadFileModel setUploadFileName:[NSString stringWithFormat:@"%@",suffixName]];
    [uploadFileModel setUploadFileSavePath:saveFile];
    [uploadFileModel setUploadTempSavePath:filePath];
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
            [weak_self readyUploadFilesWithFilePath:filePath];
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
