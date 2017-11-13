//
//  CSFileDownloadManager.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDownloadEvenHandler.h"
#import "CSDownloadTask.h"

/**
 *  下载客户端类
 *
 */
@interface CSFileDownloadManager : NSObject

/**
 *  获取单例下载客户端
 *
 *  @return
 */
+ (CSFileDownloadManager*)sharedDownloadManager;

/**
 *  指定最高下载队列容量数
 */
@property (nonatomic) int maxDownload;

/**
 *  指定最高等待队列容量数
 */
@property (nonatomic) int maxWaiting;

/**
 *  指定最高暂停队列容量数
 */
@property (nonatomic) int maxPaused;

/**
 *  指定最高重试机会
 */
@property (nonatomic) int maxFailureRetryChance;

/**
 *  已经下载任务列表
 */
@property (nonatomic) NSMutableArray *downloadedTasks;


@property (nonatomic) NSMutableArray *downloadingTasks;
/**
 *  开始一次下载任务（都统一先放进等待队列）
 *
 *  @param downloadTask    一条下载任务
 *  @param begin           下载开始前回调
 *  @param progress        处理下载中回调
 *  @param complete        完成回调
 */
- (void)downloadDataAsyncWithTask:(CSDownloadTask*)downloadTask
                            begin:(CSDownloadBeginEventHandler)begin
                         progress:(CSDownloadingEventHandler)progress
                         complete:(CSDownloadedEventHandler)complete;

/**
 *  继续一条下载任务
 *
 *  @param downloadTask 指定下载任务
 */
- (void)continueOneDownloadTaskWith:(CSDownloadTask*)downloadTask;

/**
 *  暂停一条下载任务
 *
 *  @param downloadTask 指定下载任务
 */
- (void)pauseOneDownloadTaskWith:(CSDownloadTask*)downloadTask;

/**
 *  取消一条下载任务
 *
 *  @param downloadTask 指定下载任务
 */
- (void)cancelOneDownloadTaskWith:(CSDownloadTask*)downloadTask;

/**
 *  开始全部下载任务
 */
- (void)startAllDownloadTask;

/**
 *  暂停全部下载任务
 */
- (void)pauseAllDownloadTask;

/**
 *  取消全部下载任务
 */
- (void)cancelAllDownloadTask;

/**
 *  测试队列KVO是否有效
 */
- (void)testQueueKVO;

/**
 *  添加下载任务
 *
 *  @param task
 */
-(void)addDownloadTask:(CSDownloadTask*)task;

/**
 *  获取下载任务列表
 *
 *  @return
 */
-(NSArray*)downloadTasks;


@end
