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
#import "WBCloudJsonAPI.h"
#import "Base64.h"
#import "NSError+WBCode.h"
#import "CSFileDownloadManager.h"
#import "WBCloudLocalTokenAPI.h"
#import "WBGetBoxTokenAPI.h"


@interface NetServices(){
    NSInteger _updateCount;
}

@property (nonatomic) AFNetworkReachabilityStatus status;

@end

@implementation NetServices
- (instancetype)init{
    if (self= [super init]) {
        _updateCount = 0;
    }
    return self;
}

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"NetServices dealloc");
    
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)testForLANIP:(NSString *)LANIP commplete:(void(^)(BOOL success))callback {
    /*
     * WISNUC API:SEARCH A ENABLE API TO CHECK STATUS
     */
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 3;
    [manager GET:[NSString stringWithFormat:@"%@station/info", LANIP] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        return callback(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        return callback(NO);
    }];
}

- (void)checkForLANIP:(NSString *)LANIP commplete:(void(^)(BOOL success))callback {
//    @weaky(self)
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 3;
    [manager GET:[NSString stringWithFormat:@"%@station/info", LANIP] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        return callback(YES);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        return callback(NO);
    }];
}


- (void)checkForCloudComplete:(void(^)(BOOL success))callback{
    @weaky(self)
    [weak_self getLocalTokenWithCloud:^(NSError *error, NSString *token) {
        if (!error) {
            callback(YES);
        }else{
             callback(NO);
        }
    }];
}

- (void)testAndCheckoutCloudIfSuccessComplete:(void(^)(void))callback{
    if(!WB_UserService.currentUser) return callback();
    [self checkForCloudComplete:^(BOOL success) {
        if(!success) return callback();
        [self getLocalTokenWithCloud:^(NSError *error, NSString *token) {
            if(error) return callback();
            [self updateIsCloud:YES andLocalURL:nil andCloudURL:nil];
            WB_UserService.currentUser.isCloudLogin = YES;
//            WB_UserService.currentUser.cloudToken = token;
            [WB_UserService setCurrentUser:WB_UserService.currentUser];
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"切换网络成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_CHECKOUT_TO_LAN_NOTIFY object:nil];
            return callback();
        }];
    }];
}

- (void)testAndCheckoutIfSuccessComplete:(void(^)(void))callback {
    if(!WB_UserService.currentUser) return callback();
    [self testForLANIP:WB_UserService.currentUser.localAddr commplete:^(BOOL success) {
        if(!success) return callback();
        [self getLocalTokenWithCloud:^(NSError *error, NSString *token) {
            if(error) return callback();
            [self updateIsCloud:NO andLocalURL:WB_UserService.currentUser.localAddr andCloudURL:nil];
            WB_UserService.currentUser.isCloudLogin = NO;
            WB_UserService.currentUser.localToken = token;
            [WB_UserService setCurrentUser:WB_UserService.currentUser];
            [WB_UserService synchronizedCurrentUser];
            NSLog(@"切换网络成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_CHECKOUT_TO_LAN_NOTIFY object:nil];
            return callback();
        }];
    }];
}

- (instancetype)initWithLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl {
    if(self = [super init]){
        _updateCount = 0;
        self.localUrl = localUrl;
        self.cloudUrl = cloudUrl;
        if (self.localUrl.length>0  && self.cloudUrl.length == 0) {
            self.isCloud = NO;
            [JYRequestConfig sharedConfig].baseURL = localUrl;
        }else if (self.localUrl.length == 0 && self.cloudUrl.length > 0){
            self.isCloud = YES;
            [JYRequestConfig sharedConfig].baseURL = cloudUrl;
        }
        [self checkNetwork];
    }
    return self;
}

- (void)updateIsCloud:(BOOL)isCloud andLocalURL:(NSString *)localUrl andCloudURL:(NSString *)cloudUrl {
    self.localUrl = localUrl;
    self.cloudUrl = cloudUrl;
    self.isCloud = isCloud;
    [JYRequestConfig sharedConfig].baseURL = isCloud ? cloudUrl : localUrl;
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
                [SXLoadingView showProgressHUDText:WBLocalizedString(@"network_is_disconnected", nil) duration:1];
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 
             {
                 NSLog(@"WiFi网络");
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
//                [SXLoadingView showProgressHUDText:@"正在使用手机流量" duration:1];
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

- (void)getUserBackupDirName:(NSString *)name BackupDir:(void(^)(NSError *, NSString * entryUUID))callback {
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    [self getUserBackupDirName:name BaseDir:^(NSError *error, NSString *dirUUID) {
        if(error) return callback(error, NULL);
        SaveToUserDefault(Current_Backup_Base_Entry, dirUUID);
        [self getUserBackupDirWithBackUpBaseDir:dirUUID complete:^(NSError *err, NSString *backupDirUUID) {
            if(err) return callback(err, NULL);
            SaveToUserDefault(Current_Backup_Dir, backupDirUUID);
            return callback(nil, backupDirUUID);
        }];
    }];
}

- (void)getLocalTokenWithCloud:(void(^)(NSError *, NSString * token))callback {
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    if(!WB_UserService.currentUser.cloudToken) return callback([NSError errorWithDomain:@"NO TOKEN" code:NO_CLOUD_TOKEN userInfo:nil], NULL);
    [[WBCloudLocalTokenAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSString * token = ((NSDictionary *)(request.responseJsonObject[@"data"]))[@"token"];
        return callback(nil, token);
    } failure:^(__kindof JYBaseRequest *request) {
        return callback(request.error, nil);
    }];
}

- (void)getBoxesTokenWithGuid:(NSString *)guid comlete:(void(^)(NSError *, NSString * token))callback{
    @weaky(self)
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    [[WBGetBoxTokenAPI apiWithGuid:guid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSString * token = ((NSDictionary *)request.responseJsonObject)[@"token"];
        return callback(nil, token);
    } failure:^(__kindof JYBaseRequest *request) {
        if (request.responseStatusCode == 401) {
            _updateCount ++;
            if (_updateCount<=3) {
                [weak_self performSelector:@selector(getBoxesTokenWithGuid:comlete:) withObject:guid withObject:callback];
            }else{
             return callback(request.error, nil);
            }
        }
        return callback(request.error, nil);
    }];
}

- (void)getUserHome:(void(^)(NSError *, NSString * userHome))callback{
    if(!WB_UserService.isUserLogin) return callback([NSError errorWithDomain:@"User Not Login" code:NO_USER_LOGIN userInfo:nil], NULL);
    BOOL isCloudRequest  = WB_UserService.currentUser.isCloudLogin;
    [[FLDrivesAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * responseArr = isCloudRequest ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSLog(@"%@",responseArr);
        __block BOOL find = NO;
        [responseArr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DriveModel *model = [DriveModel modelWithJSON:obj];
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

// local mkdir
/*
 * WISNUC API:local mkdir
 */
- (void)mkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, DirectoriesModel *))completeBlock{
    NSString *resource = [NSString stringWithFormat:@"drives/%@/dirs/%@/entries", WB_UserService.currentUser.userHome, dirUUID];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self currentURL], resource];
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
//        NSLog(@"%@",responseObject);
        NSDictionary * dic = responseObject[0];
        DirectoriesModel * dir = [DirectoriesModel modelWithJSON:dic[@"data"]];
        completeBlock(nil, dir);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        completeBlock(error, nil);
    }];
}

//cloud api for mkdir
- (void)cloudMkdirInDir:(NSString *)dirUUID andName:(NSString *)name completeBlock:(void(^)(NSError *, DirectoriesModel *))completeBlock{
    NSString *resource = [NSString stringWithFormat:@"drives/%@/dirs/%@/entries", WB_UserService.currentUser.userHome, dirUUID];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:[resource base64EncodedString] forKey:kCloudBodyResource];
    [dic setObject:@"POST" forKey:kCloudBodyMethod];
    [dic setObject:@"mkdir" forKey:kCloudBodyOp];
    [dic setObject:name forKey:kCloudBodyToName];
    WBCloudJsonAPI * api = [WBCloudJsonAPI apiWithBody:dic];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        DirectoriesModel *model = [DirectoriesModel modelWithJSON: request.responseJsonObject[@"data"]];
        NSLog(@"---------> cloud response <---------- \n %@", request.responseJsonObject);
        completeBlock(nil,model);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@" ------>  cloud mkdir error  <------ \n %@", request.error);
        completeBlock(request.error,nil);
    }];
}

// 获取 名为 “上传的照片” 的文件夹， 没有就创建
- (void)getUserBackupDirName:(NSString *)name BaseDir:(void(^)(NSError *, NSString * dirUUID))callback {
    FLGetDriveDirAPI * api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:WB_UserService.currentUser.userHome];
    BOOL isCloudRequest  = WB_UserService.currentUser.isCloudLogin;
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = isCloudRequest ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        //FIXME: file name equal backup base name
        __block BOOL find = NO;
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel modelWithDictionary:obj];
            if(IsEquallString(model.name, name) && IsEquallString(model.type, @"directory")) {
                *stop = YES;
                find = YES;
                return callback(NULL, model.uuid);
            }
        }];
        if(!find) {
            id block = ^(NSError *error, DirectoriesModel *entries) {
                if(error) return callback(error, nil);
                callback(nil, entries.uuid);
            };
            WB_UserService.currentUser.isCloudLogin ?
            [self cloudMkdirInDir:WB_UserService.currentUser.userHome andName:name completeBlock:block] :
            [self mkdirInDir:WB_UserService.currentUser.userHome andName:name completeBlock:block];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get root error : %@", request.error);
        callback(request.error, nil);
    }];
}

- (void)getDirUUIDWithDirName:(NSString *)name BaseDir:(void(^)(NSError *, NSString * dirUUID))callback{
    [self getUserBackupDirName:name BaseDir:callback];
}
// 获取backup 目录 ，如果没有就创建
// backupBaseDir 就是 “上传的图片” 文件夹 , backupDir 就是 “来自xxx” 文件夹
- (void)getUserBackupDirWithBackUpBaseDir:(NSString *)baseUUID complete:(void(^)(NSError *, NSString *backupDirUUID))callback {
    FLGetDriveDirAPI * api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:baseUUID];
    NSString *photoDirName = [NSString stringWithFormat:@"来自%@",[NSString deviceName]];
    BOOL isCloudRequest  = WB_UserService.currentUser.isCloudLogin;
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = isCloudRequest ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        //FIXME: file name equal backup base name
        __block BOOL find = NO;
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel modelWithDictionary:obj];
            if(IsEquallString(model.name, photoDirName) && IsEquallString(model.type, @"directory")) {
                *stop = YES;
                find = YES;
                return callback(NULL, model.uuid);
            }
        }];
        if(!find) {
            id block = ^(NSError *error, DirectoriesModel *entries) {
                if(error) return callback(error, nil);
                callback(nil, entries.uuid);
            };
            WB_UserService.currentUser.isCloudLogin ?
             [self cloudMkdirInDir:baseUUID andName:photoDirName completeBlock:block] :
            [self mkdirInDir:baseUUID andName:photoDirName completeBlock:block] 
          ;
        }
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"get backup base dir error : %@", request.error);
        callback(request.error, nil);
    }];
}

// 获取backup目录下的所有文件
- (void)getEntriesInUserBackupDir:(void(^)(NSError *, NSArray<EntriesModel *> *entries))callback{
    FLGetDriveDirAPI *api = [FLGetDriveDirAPI apiWithDrive:WB_UserService.currentUser.userHome dir:WB_UserService.currentUser.backUpDir];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSDictionary * dic = WB_UserService.currentUser.isCloudLogin ? request.responseJsonObject[@"data"] : request.responseJsonObject;
        NSArray * arr = [NSArray arrayWithArray:[dic objectForKey:@"entries"]];
        NSMutableArray * entries = [NSMutableArray arrayWithCapacity:0];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EntriesModel *model = [EntriesModel modelWithDictionary:obj];
            [entries addObject:model];
        }];
        callback(nil, entries);
    } failure:^(__kindof JYBaseRequest *request) {
        if(request.responseStatusCode == 404)
            request.error.wbCode = WBUploadDirNotFound;
        NSLog(@"get backup dir entries error : %@", request.error);
        callback(request.error, nil);
    }];
}

#pragma mark - Get nas origin image or thumbnail image
/*
 * WISNUC API:GET IMAGE(High Resolution)
 */
- (SDWebImageDownloadToken *)getHighWebImageWithHash:(NSString *)hash completeBlock:(void(^)(NSError *, UIImage *))callback {
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    [SDWebImageManager sharedManager].imageDownloader.downloadTimeout = 1000;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=data", [self currentURL], hash]];
    if(WB_UserService.currentUser.isCloudLogin)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?resource=%@&method=GET&alt=data", kCloudAddr, kCloudCommonPipeUrl, [[NSString stringWithFormat:@"media/%@", hash] base64EncodedString]]];
    return [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//        NSLog(@"SDWebImage:Error ==== %@ ==== %@",error,imageURL);
        if (image) {
            callback(nil, image);
        }else{
            callback(error, nil);
        }
    }];
    
    
//    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageCacheMemoryOnly progress:nil
//                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                    NSLog(@"SDWebImage:Error ==== %@ ==== %@",error,imageURL);
//        if (image) {
//            callback(nil, image);
//        }else{
//            callback(error, nil);
//        }
//    }];
}

/*
 * WISNUC API:GET THUMBNAIL IMAGE
 */
- (SDWebImageDownloadToken *)getThumbnailWithHash:(NSString *)hash complete:(void(^)(NSError *, UIImage *))callback {
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    [SDWebImageManager sharedManager].imageDownloader.downloadTimeout = 20000;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=thumbnail&width=200&height=200&modifier=caret&autoOrient=true", [self currentURL], hash]];
    if(WB_UserService.currentUser.isCloudLogin)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?resource=%@&method=GET&alt=thumbnail&width=200&height=200&modifier=caret&autoOrient=true", kCloudAddr, kCloudCommonPipeUrl, [[NSString stringWithFormat:@"media/%@", hash] base64EncodedString]]];
    return [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            callback(nil, image);
        }else{
            callback(error, nil);
        }
    }];
}

/*
 * WISNUC API:GET TWEET THUMBNAIL IMAGE
 */
- (SDWebImageDownloadToken *)getTweeetThumbnailImageWithHash:(NSString *)hash BoxUUID:(NSString *)boxUUID complete:(void(^)(NSError *, UIImage *))callback {
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    [SDWebImageManager sharedManager].imageDownloader.downloadTimeout = 60;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=thumbnail&width=134&height=134&modifier=caret&autoOrient=true&boxUUID=%@", [self currentURL], hash,boxUUID]];
    NSLog(@"%@,%@",hash,boxUUID);
    if(WB_UserService.currentUser.isCloudLogin)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?resource=%@&method=GET&alt=thumbnail&width=134&height=134&modifier=caret&autoOrient=true&boxUUID=%@", kCloudAddr, kCloudCommonPipeUrl, [[NSString stringWithFormat:@"media/%@", hash] base64EncodedString],boxUUID]];
    return [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            callback(nil, image);
        }else{
            callback(error, nil);
        }
    }];
}

/*
 * WISNUC API:GET TWEET IMAGE(High Resolution)
 */
- (SDWebImageDownloadToken *)getTweeethighQualityImageWithHash:(NSString *)hash BoxUUID:(NSString *)boxUUID complete:(void(^)(NSError *, UIImage *))callback {
    [SDWebImageManager sharedManager].imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:WB_UserService.currentUser.isCloudLogin ? WB_UserService.currentUser.cloudToken : [NSString stringWithFormat:@"JWT %@",WB_UserService.defaultToken] forKey:@"Authorization"];
        return dic;
    };
    [SDWebImageManager sharedManager].imageDownloader.downloadTimeout = 60;
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=data&boxUUID=%@", [self currentURL], hash,boxUUID]];
    //    NSLog(@"%@",url.absoluteString);
    if(WB_UserService.currentUser.isCloudLogin)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?resource=%@&method=GET&alt=data&boxUUID=%@", kCloudAddr, kCloudCommonPipeUrl, [[NSString stringWithFormat:@"media/%@", hash] base64EncodedString],boxUUID]];
    return [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
            callback(nil, image);
        }else{
            callback(error, nil);
            NSLog(@"%@",error);
        }
    }];
}


@end
