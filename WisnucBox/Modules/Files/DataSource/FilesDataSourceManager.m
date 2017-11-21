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
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        FilesModel *model = [FilesModel yy_modelWithJSON:request.responseJsonObject ];
        [self.dataArray addObjectsFromArray:model.entries];
        if (self.delegate && [self.delegate respondsToSelector:@selector(datasource:finishLoading:)]) {
            [self.delegate datasource:self finishLoading:YES];
        }
    } failure:^(__kindof JYBaseRequest *request) {
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
