//
//  CSUploadTaskProtocol.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef CSUploadTaskProtocol_h
#define CSUploadTaskProtocol_h
/**
 *  标记任务上传状态
 */
typedef enum
{
    CSUploadStatusTaskNotCreated = 0,       //任务还未创建（默认状态）
    CSUploadStatusWaitingForStart,         //等待启动
    CSUploadStatusUploading,             //上传中
    CSUploadStatusPaused,                  //被暂停
    CSUploadStatusWaitingForResume,        //等待恢复
    CSUploadStatusCanceled,                //被取消
    CSUploadStatusSuccess,                 //上传成功
    CSUploadStatusFailure                 //上传失败
    
} CSUploadStatus;



@protocol CSUploadTaskProtocol <NSObject>

@required
/**
 *  保存上传请求操作
 *
 *  @param UploadDataTask
 */
- (void)setUploadDataTask:(NSURLSessionDataTask *)uploadDataTask;

/**
 *  开始一条上传任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)startUploadTask:(void (^)())bindDoSomething;

/**
 *  暂停一条上传任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)pauseUploadTask:(void (^)())bindDoSomething;

/**
 *  继续一条上传任务
 *
 *  @param bindDoSomething
 */
- (void)continueUploadTask:(void (^)())bindDoSomething;

/**
 *  取消一条上传任务
 *
 *  @param bindDoSomething 附带执行的捆绑操作
 */
- (void)cancelUploadTask:(void (^)())bindDoSomething;

/**
 *  标记失败次数增1
 *
 *  @return 返回已失败次数
 */
- (int)increaseFailureCount;
#endif
@end
