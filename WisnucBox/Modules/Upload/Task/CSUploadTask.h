//
//  CSUploadTask.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSUploadTaskProtocol.h"
#import "CSUploadModel.h"
#import "CSUploadUIBindProtocol.h"

@interface CSUploadTask : NSObject <CSUploadTaskProtocol>
@property (nonatomic,getter = getUploadStatus) CSUploadStatus uploadStatus;

@property (nonatomic) NSUInteger bytesRead;

@property (nonatomic) long long totalBytesRead;

@property (nonatomic) long long totalBytesExpectedToRead;

@property (nonatomic) double bytesPerSecond;

@property (nonatomic) float progress;

@property (nonatomic,strong,getter = getUploadTaskId) NSString* uploadTaskId;


@property (nonatomic,strong,getter = getUploadFileModel) CSUploadModel* uploadFileModel;

@property (nonatomic,strong,getter = getUploadUIBinder) id<CSUploadUIBindProtocol> uploadUIBinder;

@property (nonatomic, copy) void(^progressBlock)(NSProgress *uploadProgress);
// end

- (BOOL)isEqualToUploadTask:(CSUploadTask*)uploadTask;
@end
