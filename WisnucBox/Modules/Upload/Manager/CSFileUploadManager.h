//
//  CSFileUploadManager.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSUploadEvenHandler.h"
#import "CSUploadTask.h"

/**
 *  下载管理类
 *
 */
@interface CSFileUploadManager : NSObject

/**
 *  获取单例下载管理
 *
 *  @return
 */
+ (CSFileUploadManager*)sharedUploadManager;

/**
 *  指定最高下载队列容量数
 */
@property (nonatomic) int maxUpload;

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
@property (nonatomic) NSMutableArray *uploadedTasks;


@property (nonatomic) NSMutableArray *uploadingTasks;
/**
 *  开始一次下载任务（都统一先放进等待队列）
 *
 *  @param UploadTask    一条下载任务
 *  @param begin           下载开始前回调
 *  @param progress        处理下载中回调
 *  @param complete        完成回调
 */
- (void)uploadDataAsyncWithTask:(CSUploadTask*)uploadTask
                            begin:(CSUploadBeginEventHandler)begin
                         progress:(CSUploadingEventHandler)progress
                         complete:(CSUploadedEventHandler)complete;

/**
 *  继续一条下载任务
 *
 *  @param UploadTask 指定下载任务
 */
- (void)continueOneUploadTaskWith:(CSUploadTask*)uploadTask;

/**
 *  暂停一条下载任务
 *
 *  @param UploadTask 指定下载任务
 */
- (void)pauseOneUploadTaskWith:(CSUploadTask*)uploadTask;

/**
 *  取消一条下载任务
 *
 *  @param UploadTask 指定下载任务
 */
- (void)cancelOneUploadTaskWith:(CSUploadTask*)uploadTask;

/**
 *  开始全部下载任务
 */
- (void)startAllUploadTask;

/**
 *  暂停全部下载任务
 */
- (void)pauseAllUploadTask;

/**
 *  取消全部下载任务
 */
- (void)cancelAllUploadTask;

/**
 *  测试队列KVO是否有效
 */
- (void)testQueueKVO;

/**
 *  添加下载任务
 *
 *  @param task
 */
-(void)addUploadTask:(CSUploadTask*)task;

/**
 *  获取下载任务列表
 *
 *  @return
 */
-(NSArray*)uploadTasks;

+(void)destroyAll;
@end
