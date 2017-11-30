//
//  CSUploadTask.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSUploadTask.h"
#import "NSObject+KVOBlock.h"
@implementation CSUploadTask
{
    NSURLSessionDataTask *_uploadDataTask;
    
    int _failureCount;
    
    id _uploadStatusKVO;
}

- (id)init
{
    self = [super init];
    if (self) {
        _uploadStatus = CSUploadStatusTaskNotCreated;
        [self initUploadStatusObserver];
    }
    
    return self;
}

- (void)initUploadStatusObserver
{
    _uploadStatusKVO = [self addKVOBlockForKeyPath:@"uploadStatus" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld handler:^(NSString *keyPath, id object, NSDictionary *change) {
        
        //GSUploadStatus oldStatusValue = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        
        
        CSUploadTask* task = object;
        [task.getUploadUIBinder updateUIWithTask:task];
    }];
    
}


- (BOOL)isEqualToUploadTask:(CSUploadTask*)uploadTask
{
    if ([[self getUploadTaskId]compare:[uploadTask getUploadTaskId]] == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - GSSingleUploadTaskProtocol

- (void)setUploadDataTask:(NSURLSessionDataTask *)uploadDataTask{
    _uploadDataTask = uploadDataTask;
}


- (void)startUploadTask:(void (^)())bindDoSomething
{
    [_uploadDataTask resume];
    if (bindDoSomething)
    {
        bindDoSomething();
    }
}

- (void)pauseUploadTask:(void (^)())bindDoSomething
{
    [_uploadDataTask suspend];
    
    if (bindDoSomething)
    {
        bindDoSomething();
    }
}

- (void)continueUploadTask:(void (^)())bindDoSomething
{
    if (_uploadDataTask.state == NSURLSessionTaskStateSuspended) {
        [_uploadDataTask resume];
    }
    
    if (bindDoSomething)
    {
    }
}

- (void)cancelUploadTask:(void (^)())bindDoSomething
{
    [_uploadDataTask cancel];
    
    if (bindDoSomething)
    {
        bindDoSomething();
    }
}

- (int)increaseFailureCount
{
    _failureCount++;
    
    return _failureCount;
}

#pragma mark - dealloc
- (void)dealloc
{
    NSLog(@"%@ dealloc",[self class]);
    
    [self removeKVOBlockForToken:_uploadStatusKVO];
}
@end
