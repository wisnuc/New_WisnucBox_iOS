//
//  CSUploadModel.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSUploadModel.h"

@implementation CSUploadModel
- (id)init
{
    self = [super init];
    if (self) {
        _uploadFileName       = @"";
        _getUploadFileUUID  = @"";
        _uploadFinishTime     = [NSDate date];
        _uploadFileSize       = [NSNumber numberWithLongLong:0];
        _uploadFileUserId    = @"";
        _uploadTaskURL        = @"";
        _uploadFileSavePath   = @"";
        _uploadTempSavePath   = @"";
        _uploadFilePlistURL   = @"";
    }
    
    return self;
}
@end
