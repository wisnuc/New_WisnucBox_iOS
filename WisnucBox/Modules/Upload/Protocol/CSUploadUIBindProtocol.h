//
//  CSUploadUIBindProtocol.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CSUploadUIBindProtocol_h
#define CSUploadUIBindProtocol_h


@protocol CSUploadTaskProtocol;


/**
 *  用于绑定外部UI更新操作的接口
 */
@protocol CSUploadUIBindProtocol <NSObject>

@required

/**
 *  根据任务状态改变UI
 *
 *  @param downloadTask
 */
- (void)updateUIWithTask:(id<CSUploadTaskProtocol>)uploadTask;

@end

#endif
