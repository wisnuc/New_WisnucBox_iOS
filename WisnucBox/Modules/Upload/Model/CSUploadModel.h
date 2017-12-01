//
//  CSUploadModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSUploadModel : NSObject
@property(nonatomic, strong, getter = getUploadFileName) NSString* uploadFileName;

@property(nonatomic, strong, getter = getUploadFileUUID) NSString* getUploadFileUUID;

@property(nonatomic, strong, getter = getUploadFinishTime) NSDate* uploadFinishTime;

@property(nonatomic, strong, getter = getUploadFileSize) NSNumber* uploadFileSize;

@property(nonatomic, strong, getter = getUploadFileUserId) NSString* uploadFileUserId;

@property(nonatomic, strong, getter = getUploadTaskURL) NSString* uploadTaskURL;

@property(nonatomic, strong, getter = getUploadFileSavePath) NSString* uploadFileSavePath;

@property(nonatomic, strong, getter = getUploadTempSavePath) NSString* uploadTempSavePath;

@property(nonatomic, strong, getter = getUploadFilePlistURL) NSString* uploadFilePlistURL;
@end
