//
//  CSDownloadHelper.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDownloadTask.h"
#import "CSDownloadUIBindProtocol.h"
#import "TestDataModel.h"
#import "CSFileDownloadManager.h"

@protocol DownloadHelperDelegate <NSObject>
@required//必须实现的代理方法

- (void)updateDataWithDownloadTask:(CSDownloadTask *)downloadTask;

@optional//不必须实现的代理方法

@end
@interface CSDownloadHelper : NSObject

typedef void (^HelperDownloadingEventHandler) (BOOL isDownloading);

@property(weak,nonatomic)id<DownloadHelperDelegate> delegate;
@property (nonatomic, copy) void(^progressBlock)(long long totalBytesRead, long long totalBytesExpectedToRead, float progress);
+ (CSDownloadHelper *)shareManager;

+ (void)destroyAll;

- (void)downloadFileWithFileModel:(EntriesModel *)dataModel RootUUID:(NSString *)rootUUID UUID:(NSString *)uuid;

- (void)downloadOneFileWithFileModel:(EntriesModel *)dataModel
                            RootUUID:(NSString *)rootUUID
                                UUID:(NSString *)uuid
                       IsDownloading:(HelperDownloadingEventHandler)isDownloading
                               begin:(CSDownloadBeginEventHandler)begin
                            progress:(CSDownloadingEventHandler)progress
                            complete:(CSDownloadedEventHandler)complete;

- (void)pauseDownloadWithTask:(CSDownloadTask*)downloadTask;

- (void)continueDownloadWithTask:(CSDownloadTask*)downloadTask;

- (void)cancleDownload;

@end
