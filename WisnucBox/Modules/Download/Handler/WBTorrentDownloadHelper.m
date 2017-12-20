//
//  WBTorrentDownloadHelper.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBTorrentDownloadHelper.h"
#import "CSDownloadUIBindProtocol.h"
#import "CSFileDownloadManager.h"
@interface WBTorrentDownloadHelper()<CSDownloadUIBindProtocol>
{
    CSFileDownloadManager* _manager;
    int _downdloadIdCount;
    int _downdloadCount;
    NSMutableArray * _oneDownloadArray;
}
@end


@implementation WBTorrentDownloadHelper

- (void)dealloc{
    
}
static dispatch_once_t p = 0;
__strong static id _sharedObject = nil;
+ (WBTorrentDownloadHelper *)shareManager
{
    dispatch_once(&p, ^{
        _sharedObject = [[WBTorrentDownloadHelper alloc] init];
    });
    
    return _sharedObject;
}

+ (void)destroyAll{
    p = 0;
    _sharedObject = nil;
}

@end
