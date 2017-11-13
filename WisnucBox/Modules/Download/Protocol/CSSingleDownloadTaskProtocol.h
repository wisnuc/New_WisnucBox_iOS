//
//  CSSingleDownloadTaskProtocol.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef CSSingleDownloadTaskProtocol_h
#define CSSingleDownloadTaskProtocol_h

/**
 *  标记任务下载状态
 */
typedef enum
{
    CSDownloadStatusTaskNotCreated = 0,       //任务还未创建（默认状态）
    CSDownloadStatusWaitingForStart,         //等待启动
    CSDownloadStatusDownloading,             //下载中
    CSDownloadStatusPaused,                  //被暂停
    CSDownloadStatusWaitingForResume,        //等待恢复
    CSDownloadStatusCanceled,                //被取消
    CSDownloadStatusSuccess,                 //下载成功
    CSDownloadStatusFailure                 //下载失败
    
} CSDownloadStatus;

/**
 *  定义一项下载任务接口，用于建立起对应的每款游戏下载任务，并进行对应任务的管理
 */
@protocol CSSingleDownloadTaskProtocol <NSObject>

@required

/**
 *  保存下载请求操作
 *
 *  @param downloadDataTask
 */
- (void)setDownloadDataTask:(NSURLSessionDataTask *)downloadDataTask;

/**
 *  开始一条下载任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)startDownloadTask:(void (^)())bindDoSomething;

/**
 *  暂停一条下载任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)pauseDownloadTask:(void (^)())bindDoSomething;

/**
 *  继续一条下载任务
 *
 *  @param bindDoSomething
 */
- (void)continueDownloadTask:(void (^)())bindDoSomething;

/**
 *  取消一条下载任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)cancelDownloadTask:(void (^)())bindDoSomething;

/**
 *  标记失败次数增1
 *
 *  @return 返回已失败次数
 */
- (int)increaseFailureCount;

@end
#endif /* CSSingleDownloadTaskProtocol_h */
