//
//  CSUploadHelper.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/30.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSUploadTask.h"
#import "CSUploadUIBindProtocol.h"
#import "CSFileUploadManager.h"
@protocol UploadHelperDelegate <NSObject>
@required//必须实现的代理方法

- (void)updateDataWithUploadTask:(CSUploadTask *)uploadTask;

@optional//不必须实现的代理方法
@end
@interface CSUploadHelper : NSObject
+ (CSUploadHelper *)shareManager;

+ (void)destroyAll;

@property(weak,nonatomic)id<UploadHelperDelegate> delegate;
@end
