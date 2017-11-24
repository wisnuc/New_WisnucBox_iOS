//
//  CSFilesOneDownloadManager.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSFileDownloadManager.h"

@interface CSFilesOneDownloadManager : NSObject
+ (CSFilesOneDownloadManager*)shareManager;
+ (void)destroyAll;
- (void)beginDownloadTask:(CSDownloadTask*)downloadTask
                    begin:(CSDownloadBeginEventHandler)begin
                 progress:(CSDownloadingEventHandler)progress
                 complete:(CSDownloadedEventHandler)complete;
- (void)cancelOneDownloadTaskWith:(CSDownloadTask*)downloadTask;
@end
