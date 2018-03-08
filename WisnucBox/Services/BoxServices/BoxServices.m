//
//  BoxServices.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2018/1/31.
//  Copyright © 2018年 JackYang. All rights reserved.
//

#import "BoxServices.h"
#import "PHAsset+JYEXT.h"


@interface BoxServices(){
//     AFHTTPSessionManager * _manager;
}
@property (nonatomic,strong) NSMutableArray *requestFileIDArray;
//@property (nonatomic) NSURLSessionDataTask * dataTask;
@end

@implementation BoxServices


- (void)abort {
    
}


- (void)sendTweetWithFilesDic:(NSDictionary *)dic Boxuuid:(NSString *)boxuuid Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback{
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithDictionary:dic copyItems:YES];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *filesArr = dataDic[@"filesModel"];
   
    [filesArr enumerateObjectsUsingBlock:^(EntriesModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [uploadDic setObject:model.name forKey:@"filename"];
        [uploadDic setObject:dataDic[@"dirUUID"] forKey:@"dirUUID"];
        [uploadDic setObject:dataDic[@"driveUUID"] forKey:@"driveUUID"];
        [uploadDic setObject:@"file" forKey:@"type"];
        [dataArray addObject:uploadDic];
    }];
    /*
     * WISNUC API:SEND A TWEET 
     */
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 200000;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString;
    if (WB_UserService.currentUser.isCloudLogin) {
        urlString = [NSString stringWithFormat:@"%@%@/%@/%@", kCloudAddr, kCloudCommonBoxesUrl,boxuuid,kCloudCommonBoxesPipeUrl];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
    }else{
        urlString = [NSString stringWithFormat:@"%@boxes/%@/tweets",[JYRequestConfig sharedConfig].baseURL,boxuuid];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@ %@", WB_BoxService.boxToken,WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    }
    NSData *josnData;
    NSMutableDictionary *dataMutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (WB_UserService.currentUser.isCloudLogin) {
        NSString *requestUrl = [NSString stringWithFormat:@"/boxes/%@/tweets",boxuuid];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
        [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
        [manifestDic setObject:resource forKey:kCloudBodyResource];
        [manifestDic setObject:@"" forKey:@"comment"];
        [manifestDic setObject:@"list" forKey:@"type"];

        if (dataArray.count>0)
            [manifestDic setObject:dataArray forKey:@"indrive"];
        
        NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
        [dataMutableDic setObject:result forKey:@"manifest"];
        NSLog(@"%@",dataMutableDic);
    }else{
        [dataMutableDic setObject:@"" forKey:@"comment"];
        [dataMutableDic setObject:@"list" forKey:@"type"];
        if (dataArray.count>0)[dataMutableDic setObject:dataArray forKey:@"indrive"];
        
         josnData = [NSJSONSerialization dataWithJSONObject:dataMutableDic options:NSJSONWritingPrettyPrinted error:nil];
        dataMutableDic = nil;
    }

    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:dataMutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (!WB_UserService.currentUser.isCloudLogin) {
            [formData appendPartWithFormData:josnData name:@"list"];
        }else{
            
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? responseObject[@"data"] : responseObject;
        WBTweetModel *model = [WBTweetModel modelWithDictionary:responseDic];
        NSLog(@"%@",model.uuid);
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        callback(nil,error);
    }];
    [dataTask resume];
}

- (void)sendTweetWithImageArray:(NSArray *)array BoxModel:(WBBoxesModel *)boxModel Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback{
    NSMutableArray *localImageListArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *netImageListArray = [NSMutableArray arrayWithCapacity:0];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[WBAsset class]]) {
            NSString * hashString = ((WBAsset *)obj).fmhash;
            NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
            [mutableDic setObject:@"media" forKey:@"type"];
            [mutableDic setObject:hashString forKey:@"sha256"];
            [netImageListArray addObject:mutableDic];
            
        }else{
            JYAsset *jyasset = obj;
            PHImageRequestID requestFileID =  [jyasset.asset getFile:^(NSError *requestError, NSString *filePath) {
                if(requestError)
                    return callback(nil,requestError);
                if (filePath.length==0) return;
               __block NSString * hashString = jyasset.digest;
    
                if (!hashString || hashString.length==0) {
                    hashString  = [FileHash sha256HashOfFileAtPath:filePath];
                }
       
                if (!hashString || hashString.length==0) {
                    return;
                }
                NSInteger sizeNumber = (NSInteger)[WB_FileService fileSizeAtPath:filePath];
                NSString * exestr = [filePath lastPathComponent];
                NSString * fileName = [PHAssetResource assetResourcesForAsset:jyasset.asset].firstObject.originalFilename;
                if(IsNilString(fileName)) {
                    fileName = exestr;
                }
                
                NSMutableDictionary * mutableDicx = [NSMutableDictionary dictionaryWithCapacity:0];
                [mutableDicx setObject:filePath forKey:@"filePath"];
                [mutableDicx setObject:@(sizeNumber) forKey:@"size"];
                [mutableDicx setObject:fileName forKey:@"filename"];
                [mutableDicx setObject:hashString forKey:@"sha256"];
               
                [localImageListArray addObject:mutableDicx];
            }];
            [_requestFileIDArray addObject:@(requestFileID)];
        }
    }];
   
    [self creatAtweetWithNetImageListArray:netImageListArray LocalImageListArray:localImageListArray  BoxModel:boxModel   Complete:callback];
}


- (void)creatAtweetWithNetImageListArray:(NSArray *)netImageListArray LocalImageListArray:(NSArray *)localImageListArray  BoxModel:(WBBoxesModel *)boxModel  Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback{
    
   __block NSMutableArray *localDataArray = [[NSMutableArray alloc]initWithArray:localImageListArray copyItems:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 200000;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString;
    if (WB_UserService.currentUser.isCloudLogin) {
        urlString =  [NSString stringWithFormat:@"%@%@/%@/%@", kCloudAddr, kCloudCommonBoxesUrl,boxModel.uuid,kCloudCommonBoxesPipeUrl];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
    }else{
        NSLog(@"%@",WB_UserService.currentUser.cloudToken);
        if ([WB_UserService.currentUser.stationId isEqualToString:boxModel.station.stationId]) {
            urlString = [NSString stringWithFormat:@"%@boxes/%@/tweets",[JYRequestConfig sharedConfig].baseURL,boxModel.uuid];
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@ %@", WB_BoxService.boxToken,WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
        }else{
            urlString =  [NSString stringWithFormat:@"%@%@/%@/%@", kCloudAddr, kCloudCommonBoxesUrl,boxModel.uuid,kCloudCommonBoxesPipeUrl];
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", WB_UserService.currentUser.cloudToken] forHTTPHeaderField:@"Authorization"];
        }
      
    }
    NSData *josnData;
    NSMutableDictionary *dataMutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (WB_UserService.currentUser.isCloudLogin) {
        NSString *requestUrl = [NSString stringWithFormat:@"/boxes/%@/tweets",boxModel.uuid];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
        [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
        [manifestDic setObject:resource forKey:kCloudBodyResource];
        [manifestDic setObject:@"" forKey:@"comment"];
        [manifestDic setObject:@"list" forKey:@"type"];
        if (localImageListArray.count>0) {
            [localImageListArray enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeObjectForKey:@"filePath"];
            }];
            
            NSLog(@"%@",localImageListArray);
            [manifestDic setObject:localImageListArray forKey:@"list"];
        }
        if (netImageListArray.count>0) {
            [manifestDic setObject:netImageListArray forKey:@"indrive"];
        }
//        dataMutableDic = manifestDic;
        NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
        [dataMutableDic setObject:result forKey:@"manifest"];

    }else{
       
        if (![WB_UserService.currentUser.stationId isEqualToString:boxModel.station.stationId]) {
            NSString *requestUrl = [NSString stringWithFormat:@"/boxes/%@/tweets",boxModel.uuid];
            NSString *resource =[requestUrl base64EncodedString] ;
            NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
            [manifestDic setObject:@"POST" forKey:kCloudBodyMethod];
            [manifestDic setObject:resource forKey:kCloudBodyResource];
            [manifestDic setObject:@"" forKey:@"comment"];
            [manifestDic setObject:@"list" forKey:@"type"];
            if (localImageListArray.count>0) {
                [localImageListArray enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj removeObjectForKey:@"filePath"];
                }];
                
                NSLog(@"%@",localImageListArray);
                [manifestDic setObject:localImageListArray forKey:@"list"];
            }
            if (netImageListArray.count>0) {
                [manifestDic setObject:netImageListArray forKey:@"indrive"];
            }
            //        dataMutableDic = manifestDic;
            NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
            [dataMutableDic setObject:result forKey:@"manifest"];
        }else{
            [dataMutableDic setObject:@"" forKey:@"comment"];
            [dataMutableDic setObject:@"list" forKey:@"type"];
            
            if (localImageListArray.count>0) {
                [localImageListArray enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj removeObjectForKey:@"filePath"];
                }];
                
                NSLog(@"%@",localImageListArray);
                [dataMutableDic setObject:localImageListArray forKey:@"list"];
            }
            if (netImageListArray.count>0) {
                [dataMutableDic setObject:netImageListArray forKey:@"indrive"];
            }
            josnData = [NSJSONSerialization dataWithJSONObject:dataMutableDic options:NSJSONWritingPrettyPrinted error:nil];
            dataMutableDic = nil;
            
        }
    }
  
    
    __block NSString *filePath;
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:dataMutableDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (!WB_UserService.currentUser.isCloudLogin) {
            if (![WB_UserService.currentUser.stationId isEqualToString:boxModel.station.stationId]) {
            }else{
            [formData appendPartWithFormData:josnData name:@"list"];
            }
        }else{
            
        }
        if (localImageListArray.count>0) {
            [localDataArray enumerateObjectsUsingBlock:^(NSMutableDictionary *mutableDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                [dic setObject:[mutableDic objectForKey:@"size"]  forKey:@"size"];
                [dic setObject:[mutableDic objectForKey:@"sha256"]  forKey:@"sha256"];
                filePath =[mutableDic objectForKey:@"filePath"];
                NSError *formdataError;
                NSData *jsonFileNameData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString =  [[NSString alloc] initWithData:jsonFileNameData  encoding:NSUTF8StringEncoding];
                NSLog(@"%@",filePath);
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"" fileName:jsonString mimeType:@"application/octet-stream" error:&formdataError];
            }];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * responseDic = WB_UserService.currentUser.isCloudLogin ? responseObject[@"data"] : responseObject;
        WBTweetModel *model = [WBTweetModel modelWithDictionary:responseDic];
         NSLog(@"%@",model.uuid);
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"失败,%@",serializedData);
        }
        callback(nil,error);
    }];
    [dataTask resume];
//    }
    
}

- (NSString *)boxToken{
    __block NSString *tokenForBox;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970];
    if (WB_UserService.currentUser.boxToken && (time-[self boxTokenDateLongLongValue]<3600.00)) {
        return WB_UserService.currentUser.boxToken;
    }
    
    if (!WB_UserService.currentUser.guid) {
        return nil;
    }
    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
    [WB_NetService getBoxesTokenWithGuid:WB_UserService.currentUser.guid comlete:^(NSError *error, NSString *token) {
        if (!error) {
            tokenForBox = token;
        }
        dispatch_semaphore_signal(signal);
    }];
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    return tokenForBox;
}

- (NSTimeInterval)boxTokenDateLongLongValue{
    NSTimeInterval resultTime = 0.0;
    if (WB_UserService.currentUser.boxTokenDate) {
        NSDate* date = WB_UserService.currentUser.boxTokenDate;
        NSTimeInterval time=[date timeIntervalSince1970];
        resultTime = time;
        return resultTime;
    }else{
        return resultTime;
    }
}

- (void)saveBoxesTokenWithGuid:(NSString *)guid {
    [WB_NetService getBoxesTokenWithGuid:guid comlete:^(NSError *error, NSString *token) {
        if (!error) {
            WB_UserService.currentUser.boxToken = token;
            WB_UserService.currentUser.boxTokenDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [WB_UserService setCurrentUser:WB_UserService.currentUser];
            [WB_UserService synchronizedCurrentUser];
        }else{
            NSLog(@"%@",error);
        }
    }];
}

- (void)cancel{
    [_requestFileIDArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[PHImageManager defaultManager] cancelImageRequest:[obj intValue]];
    }];
}

- (NSMutableArray *)requestFileIDArray{
    if (!_requestFileIDArray) {
        _requestFileIDArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _requestFileIDArray;
}

@end
