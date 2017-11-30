//
//  CSUploadEvenHandler.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSUploadTask.h"
#ifndef CSUploadEvenHandler_h
#define CSUploadEvenHandler_h
/**
 *  异步上传开始前，执行自定义的事件
 *
 *  @return
 */
typedef void (^CSUploadBeginEventHandler) ();

/**
 *  异步上传中，执行自定义的事件
 *
 *  @param bytesRead                距离上次执行后又上传了多少字节
 *  @param totalBytesRead           已经上传了多少字节
 *  @param totalBytesExpectedToRead 总共需要上传多少字节
 *  @param bytesPerSecond           实时上传速度(Bytes/s)
 *
 *  @return
 */
typedef void (^CSUploadingEventHandler) (NSProgress* uploadProgress);

/**
 *  异步上传结束后，执行自定义的事件
 *
 *  @param error 错误对象（如果成功，error传nil）
 *
 *  @return
 */
typedef void (^CSUploadedEventHandler) (CSUploadTask *uploadTask,NSError* error );


#endif /* CSUploadEvenHandler_h */
