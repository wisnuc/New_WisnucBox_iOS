//
//  CSDownloadUIBindProtocol.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef CSDownloadUIBindProtocol_h
#define CSDownloadUIBindProtocol_h


@protocol CSSingleDownloadTaskProtocol;


/**
 *  用于绑定外部UI更新操作的接口
 */
@protocol CSDownloadUIBindProtocol <NSObject>

@required

/**
 *  根据任务状态改变UI
 *
 *  @param downloadTask
 */
- (void)updateUIWithTask:(id<CSSingleDownloadTaskProtocol>)downloadTask;

@end

#endif /* CSDownloadUIBindProtocol_h */
