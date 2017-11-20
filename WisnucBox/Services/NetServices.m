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

@interface NetServices()

@property (nonatomic) AFNetworkReachabilityStatus status;

@end

@implementation NetServices

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"NetServices dealloc");
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl {
    if(self = [super init]){
        self.localUrl = localUrl;
        self.cloudUrl = cloudUrl;
        self.isCloud = NO;
        [JYRequestConfig sharedConfig].baseURL = localUrl;
        [self checkNetwork];
    }
    return self;
}

- (void)checkNetwork

{
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    @weaky(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
             {
                 NSLog(@"无网络");
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 
             {
                 NSLog(@"WiFi网络");
                 
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
                 NSLog(@"手机网络");
                 break;
             }
             default:{
                 NSLog(@"未知网络");
                 break;
             }
         }
         weak_self.status = status;
         [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_REACHABILITY_CHANGE_NOTIFY object:@(status)];
     }];
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

- (void)mkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, DirectoriesModel *))completeBlock{
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
        NSDictionary * dic = responseObject[0];
        DirectoriesModel * dir = [DirectoriesModel yy_modelWithJSON:dic[@"data"]];
        completeBlock(nil, dir);
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
            [self mkdirInDir:WB_UserService.currentUser.userHome andName:BackUpBaseDirName completeBlock:^(NSError *error, DirectoriesModel *entries) {
                if(error) return callback(error, nil);
                callback(nil, entries.uuid);
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
            [self mkdirInDir:baseUUID andName:photoDirName completeBlock:^(NSError *error, DirectoriesModel *entries) {
                if(error) return callback(error, nil);
                callback(nil, entries.uuid);
            }];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get backup base dir error : %@", request.error);
        callback(request.error, nil);
    }];
}

- (void)getEntriesInUserBackupDir:(void(^)(NSError *, NSArray<EntriesModel *> *entries))callback{
    FLGetDriveDirAPI *api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:WB_UserService.currentUser.backUpDir];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        NSMutableArray * entries = [NSMutableArray arrayWithCapacity:0];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel yy_modelWithDictionary:obj];
            [entries addObject:model];
        }];
        callback(nil, entries);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get backup dir entries error : %@", request.error);
        callback(request.error, nil);
    }];
}

- (id <SDWebImageOperation>)getHighWebImageWithHash:(NSString *)hash completeBlock:(void(^)(NSError *, UIImage *))callback {
//    [[SDImageCache sharedImageCache] setShouldDecompressImages:NO];
//    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=data", [self currentURL], hash]];
    return [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageCacheMemoryOnly progress:nil
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            callback(nil, image);
        }else{
            callback(error, nil);
        }
    }];
}


- (id <SDWebImageOperation>)getThumbnailWithHash:(NSString *)hash complete:(void(^)(NSError *, UIImage *))callback {
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:[NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=thumbnail&width=200&height=200&modifier=caret&autoOrient=true", [self currentURL], hash]];
    return [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil
                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                             if (image) {
                                                                 callback(nil, image);
                                                             }else{
                                                                 callback(error, nil);
                                                             }
                                                         }];
}

@end
