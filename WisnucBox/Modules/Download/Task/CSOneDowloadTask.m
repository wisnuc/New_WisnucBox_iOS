//
//  CSOneDowloadTask.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/24.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSOneDowloadTask.h"


@implementation CSOneDowloadTask
{
    NSURLSessionDataTask *_downloadDataTask;
    
}

- (void)cancelDownloadTask:(void (^)())bindDoSomething
{
    [_downloadDataTask cancel];
    
    if (bindDoSomething)
    {
        bindDoSomething();
    }
}


- (id)init
{
    self = [super init];
    if (self) {
        _downloadStatus = CSDownloadStatusTaskNotCreated;
//        [self initDownloadStatusObserver];
    }
    
    return self;
}

- (void)setDownloadDataTask:(NSURLSessionDataTask *)downloadDataTask{
    _downloadDataTask = downloadDataTask;
}

@end
