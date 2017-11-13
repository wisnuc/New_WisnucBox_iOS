//
//  NetServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "NetServices.h"
#import "NSString+DeviceName.h"
#import "FLGetDriveDirAPI.h"
#import "FLDrivesAPI.h"

#define BackUpBaseDirName @"上传的照片"

@implementation NetServices

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"NetServices dealloc");
}

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl {
    if(self = [super init]){
        self.localUrl = localUrl;
        self.cloudUrl = cloudUrl;
        self.isCloud = NO;
    }
    return self;
}

- (NSString *)currentURL {
    return WB_UserService.currentUser.isCloudLogin ? _cloudUrl : _localUrl;
}

- (NSString *)currentToken {
    return WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : WB_UserService.currentUser.localToken;
}

- (void)getUserBackupDir:(void(^)(NSError *, NSString * entryUUID))callback {
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    [self getUserBackupBaseDir:^(NSError *error, NSString *dirUUID) {
        if(error) return callback(error, NULL);
        SaveToUserDefault(Current_Backup_Base_Entry, dirUUID);
        [self getUserBackupDirWithBackUpBaseDir:dirUUID complete:^(NSError *err, NSString *backupDirUUID) {
            if(err) return callback(err, NULL);
            SaveToUserDefault(Current_Backup_Dir, backupDirUUID);
            return callback(nil, backupDirUUID);
        }];
    }];
}

- (void)getUserHome:(void(^)(NSError *, NSString * userHome))callback{
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    [[FLDrivesAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * responseArr = request.responseJsonObject;
        NSLog(@"%@",responseArr);
        __block BOOL find = NO;
        [responseArr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DriveModel *model = [DriveModel yy_modelWithJSON:obj];
            if(IsEquallString(model.tag, @"home")){
                *stop = YES;
                find = YES;
                return callback(nil, model.uuid);
            }
        }];
        if(!find) {
            NSLog(@"User Home Not Found");
            return callback([NSError errorWithDomain:@"User Home Not Found" code:60004 userInfo:nil], NULL);
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get user home error: %@", request.error);
        return callback(request.error, NULL);
    }];
}

- (void)mkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, NSArray<EntriesModel *> *))completeBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries", [self currentURL], WB_UserService.currentUser.userHome, dirUUID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",[self currentToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDictionary *dic= @{@"op": @"mkdir"};
        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [formData appendPartWithFormData:data name:name];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * arr = [dic objectForKey:@"entries"];
        NSMutableArray * entries = [NSMutableArray arrayWithCapacity:0];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel yy_modelWithDictionary:obj];
            [entries addObject:model];
        }];
        completeBlock(NULL, entries);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        completeBlock(error, nil);
    }];
}

- (void)getUserBackupBaseDir:(void(^)(NSError *, NSString * dirUUID))callback {
    FLGetDriveDirAPI * api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:WB_UserService.currentUser.userHome];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        //FIXME: file name equal backup base name
        __block BOOL find = NO;
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel yy_modelWithDictionary:obj];
            if(IsEquallString(model.name, BackUpBaseDirName) && IsEquallString(model.type, @"directory")) {
                *stop = YES;
                find = YES;
                return callback(NULL, model.uuid);
            }
        }];
        if(!find) {
            [self mkdirInDir:WB_UserService.currentUser.userHome andName:BackUpBaseDirName completeBlock:^(NSError *error, NSArray<EntriesModel *> *entries) {
                if(error) return callback(error, nil);
                __block BOOL find = NO;
                [entries enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(IsEquallString(obj.name,  BackUpBaseDirName)){
                        *stop = YES;
                        find = YES;
                        return callback(NULL, obj.uuid);
                    }
                }];
                if(!find) return callback([NSError errorWithDomain:@"create success but notfound" code:60002 userInfo:nil], nil);
            }];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get root error : %@", request.error);
        callback(request.error, nil);
    }];
}

- (void)getUserBackupDirWithBackUpBaseDir:(NSString *)baseUUID complete:(void(^)(NSError *, NSString *backupDirUUID))callback {
    FLGetDriveDirAPI * api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:baseUUID];
    NSString *photoDirName = [NSString stringWithFormat:@"来自%@",[NSString deviceName]];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        //FIXME: file name equal backup base name
        __block BOOL find = NO;
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel yy_modelWithDictionary:obj];
            if(IsEquallString(model.name, photoDirName) && IsEquallString(model.type, @"directory")) {
                *stop = YES;
                find = YES;
                return callback(NULL, model.uuid);
            }
        }];
        if(!find) {
            [self mkdirInDir:baseUUID andName:photoDirName completeBlock:^(NSError *error, NSArray<EntriesModel *> *entries) {
                if(error) return callback(error, nil);
                __block BOOL find = NO;
                [entries enumerateObjectsUsingBlock:^(EntriesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(IsEquallString(obj.name,  photoDirName)){
                        *stop = YES;
                        find = YES;
                        return callback(NULL, obj.uuid);
                    }
                }];
                if(!find) return callback([NSError errorWithDomain:@"create success but notfound" code:60002 userInfo:nil], nil);
            }];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get backup base dir error : %@", request.error);
        callback(request.error, nil);
    }];
}

@end
