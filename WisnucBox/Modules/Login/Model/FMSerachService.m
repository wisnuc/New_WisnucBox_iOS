//
//  FMSerachService.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSerachService.h"
#import "UserModel.h"

@implementation FMSerachService

-(void)setPath:(NSString *)path{
    _path = path;
    self.isReadly = NO;
    [self getData];
    
}
-(NSArray *)users{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

-(void)getData{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    _task = [manager GET:[NSString stringWithFormat:@"%@users",_path] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * userArr = responseObject;
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel yy_modelWithJSON:dic];
            [tempArr addObject:model];
        }
        self.users = tempArr;
        self.isReadly = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
@end
