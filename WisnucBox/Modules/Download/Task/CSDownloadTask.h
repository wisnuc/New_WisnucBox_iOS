//
//  CSDownloadTask.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CSSingleDownloadTaskProtocol.h"
#import "CSDownloadModel.h"
#import "CSDownloadUIBindProtocol.h"

/**
 *  实现下载任务（依赖GSSingleDownloadTaskProtocol协议）
 *  外部使用前，需要指定下载文件模型(实现GSDownloadFileModelProtocol接口)和关联的UI对象(实现GSDownloadUIBindProtocol)
 */
@interface CSDownloadTask : NSObject <CSSingleDownloadTaskProtocol>

@property (nonatomic,getter = getDownloadStatus) CSDownloadStatus downloadStatus;

// add by zhenwei
@property (nonatomic) NSUInteger bytesRead;

@property (nonatomic) long long totalBytesRead;

@property (nonatomic) long long totalBytesExpectedToRead;

@property (nonatomic) double bytesPerSecond;

@property (nonatomic) float progress;

@property (nonatomic,strong,getter = getDownloadTaskId) NSString* downloadTaskId;

@property (nonatomic, strong) NSOutputStream *stream;

@property (nonatomic,strong,getter = getDownloadFileModel) CSDownloadModel* downloadFileModel;

@property (nonatomic,strong,getter = getDownloadUIBinder) id<CSDownloadUIBindProtocol> downloadUIBinder;

@property (nonatomic, copy) void(^progressBlock)(long long totalBytesRead, long long totalBytesExpectedToRead, float progress);
// end

- (BOOL)isEqualToDownloadTask:(CSDownloadTask*)downloadTask;
//@property (nonatomic,strong)NSURLSessionDataTask *downloadDataTask;
@end
