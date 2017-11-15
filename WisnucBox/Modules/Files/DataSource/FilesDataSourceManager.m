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

@implementation FilesDataSourceManager

+ (instancetype)manager{
    static FilesDataSourceManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FilesDataSourceManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)getFilesWithUUID:(NSString *)uuid{
    FLGetDriveDirAPI *api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:uuid];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        FilesModel *model = [FilesModel yy_modelWithJSON:request.responseJsonObject ];
        [self.dataArray addObjectsFromArray:model.entries];
        if (self.delegate && [self.delegate respondsToSelector:@selector(datasource:finishLoading:)]) {
            [self.delegate datasource:self finishLoading:YES];
        }
        NSLog(@"%@",self.dataArray);
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
