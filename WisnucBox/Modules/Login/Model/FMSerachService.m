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
//    self.isReadly = NO;
//    [self getData];
}

- (void)getData{
    self.isReadly = NO;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 40;
    _task = [manager GET:[NSString stringWithFormat:@"%@users",self.path] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSArray * userArr = responseObject;
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel modelWithJSON:dic];
            if (![model.disabled boolValue]) {
                [tempArr addObject:model];
            }
        }
        self.users = tempArr;
        self.isReadly = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
     
    }];
}

-(NSArray *)users{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

-(void)getDataWithPath:(NSString *)path Block:(void(^)(NSArray *dataArray))block{
    self.isReadly = NO;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 40;
    _task = [manager GET:[NSString stringWithFormat:@"%@users",path] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        NSArray * userArr = responseObject;
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel modelWithJSON:dic];
            if (![model.disabled boolValue]) {
                [tempArr addObject:model];
            }
        }
        self.users = tempArr;
        self.isReadly = YES;
        block(tempArr);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    block(nil);
    }];
}
@end
