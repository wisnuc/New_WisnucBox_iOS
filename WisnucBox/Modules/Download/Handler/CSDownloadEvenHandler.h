//
//  CSDownloadEvenHandler.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#ifndef CSDownloadEvenHandler_h
#define CSDownloadEvenHandler_h
/**
 *  异步下载开始前，执行自定义的事件
 *
 *  @return
 */
typedef void (^CSDownloadBeginEventHandler) ();

/**
 *  异步下载中，执行自定义的事件
 *
 *  @param bytesRead                距离上次执行后又下载了多少字节
 *  @param totalBytesRead           已经下载了多少字节
 *  @param totalBytesExpectedToRead 总共需要下载多少字节
 *  @param bytesPerSecond           实时下载速度(Bytes/s)
 *
 *  @return
 */
typedef void (^CSDownloadingEventHandler) (long long totalBytesRead, long long totalBytesExpectedToRead, float progress);

/**
 *  异步下载结束后，执行自定义的事件
 *
 *  @param error 错误对象（如果成功，error传nil）
 *
 *  @return
 */
typedef void (^CSDownloadedEventHandler) (NSError* error );


#endif /* CSDownloadEvenHandler_h */
