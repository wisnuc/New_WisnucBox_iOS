//
//  CSOneDowloadTask.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSingleDownloadTaskProtocol.h"
#import "CSDownloadModel.h"
#import "CSDownloadUIBindProtocol.h"

@interface CSOneDowloadTask : NSObject <CSSingleDownloadTaskProtocol>
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

@property (nonatomic, copy) void(^progressBlock)(NSProgress *downloadProgress);
// end

@end
