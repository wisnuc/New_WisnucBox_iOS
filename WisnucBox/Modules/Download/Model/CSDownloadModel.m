//
//  CSDownloadModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/7.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSDownloadModel.h"

@implementation CSDownloadModel

- (id)init
{
    self = [super init];
    if (self) {
        _downloadFileName       = @"";
//        _downloadFileAvatorURL  = @"";
        _downloadFinishTime     = [NSDate date];
        _downloadFileSize       = [NSNumber numberWithLongLong:0];
        _downloadFileUserId    = @"";
        _downloadTaskURL        = @"";
        _downloadFileSavePath   = @"";
        _downloadTempSavePath   = @"";
        _downloadFilePlistURL   = @"";
    }
    
    return self;
}
@end
