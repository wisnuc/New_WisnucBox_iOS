//
//  FilesDataSourceManager.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FilesDataSourceManager.h"
#import "FLGetDriveDirAPI.h"
#import "FilesModel.h"
#import "FLDrivesAPI.h"

@implementation FilesDataSourceManager

static FilesDataSourceManager * manager = nil;
static dispatch_once_t onceToken;

+ (instancetype)manager{
    dispatch_once(&onceToken, ^{
        manager = [FilesDataSourceManager new];
    });
    return manager;
}

+ (void)destroyAll{
    onceToken = 0;
    manager = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}



- (void)getFilesWithDriveUUID:(NSString *)driveUUID DirUUID:(NSString *)uuid{
    FLGetDriveDirAPI *api = [FLGetDriveDirAPI apiWithDrive:driveUUID dir:uuid];
//     NSLog(@"%@",api.requestUrl);
    
    [SXLoadingView showProgressHUD:WBLocalizedString(@"loading...", nil)];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        FilesModel *model = [FilesModel modelWithJSON:responseDic];
        [model.entries enumerateObjectsUsingBlock:^(EntriesModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.driveUUID = driveUUID;
            obj.parentUUID = uuid;
        }];
        [self.dataArray addObjectsFromArray:model.entries];
        if (self.delegate && [self.delegate respondsToSelector:@selector(datasource:finishLoading:)]) {
            [self.delegate datasource:self finishLoading:YES];
        }
        [SXLoadingView hideProgressHUD];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        NSLog(@"%@",request.error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(datasource:finishLoading:)]) {
            [self.delegate datasource:self finishLoading:NO];
        }
    }];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

@end
