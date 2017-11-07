//
//  CSFileDownloadManager.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSDownloadModel.h"

@interface CSFileDownloadManager : NSObject

+(__kindof CSFileDownloadManager *)shareManager;
/** 下载进度条 */
@property (strong, nonatomic)  UIProgressView *progressView;
/** 下载进度条Label */
@property (strong, nonatomic)  UILabel *progressLabel;

/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/** 文件的总长度 */
@property (nonatomic, assign) long long fileLength;
/** 当前下载长度 */
@property (nonatomic, assign) long long currentLength;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/* AFURLSessionManager */
@property (nonatomic, strong) AFURLSessionManager *manager;

@property (nonatomic, assign) BOOL isSuspend;

- (void)downloadWithDownloadURLString:(NSString *)downloadURLString progress:(DownloadProgressBlock)progress state:(DownloadStateBlock)state;
- (void)OfflinResumeDownload:(BOOL)sender;

- (void)removeFiles;

@end
