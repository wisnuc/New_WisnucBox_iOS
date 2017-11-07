//
//  CSDownloadModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/7.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadProgress;
@class CSDownloadModel;

typedef NS_ENUM(NSUInteger, DownloadState) {
    DownloadStateNone,        // 未下载
    DownloadStateReadying,    // 等待下载
    DownloadStateRunning,     // 正在下载
    DownloadStateSuspended,   // 下载暂停
    DownloadStateCompleted,   // 下载完成
    DownloadStateFailed       // 下载失败
};

@interface CSDownloadModel : NSObject
// 进度更新block
typedef void (^DownloadProgressBlock)(DownloadProgress *progress);
// 状态更新block
typedef void (^DownloadStateBlock)(DownloadState state,NSString *filePath, NSError *error);
@end
/**
 *  下载进度
 */
@interface DownloadProgress : NSObject

// 续传大小
@property (nonatomic, assign, readonly) int64_t resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign, readonly) int64_t bytesWritten;
// 已下载的数量
@property (nonatomic, assign, readonly) int64_t totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign, readonly) int64_t totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign, readonly) float progress;
// 下载速度
@property (nonatomic, assign, readonly) float speed;
// 下载剩余时间
@property (nonatomic, assign, readonly) int remainingTime;

@end
