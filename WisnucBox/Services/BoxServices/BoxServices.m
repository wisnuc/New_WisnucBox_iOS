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

- (void)sendTweetWithImageArray:(NSArray *)array Boxuuid:(NSString *)boxuuid Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback{
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
   
    [self creatAtweetWithNetImageListArray:netImageListArray LocalImageListArray:localImageListArray   Boxuuid:boxuuid   Complete:callback];
}

- (void)creatAtweetWithNetImageListArray:(NSArray *)netImageListArray LocalImageListArray:(NSArray *)localImageListArray  Boxuuid:(NSString *)boxuuid  Complete:(void(^)(WBTweetModel *tweetModel,NSError *error))callback{
   __block NSMutableArray *localDataArray = [[NSMutableArray alloc]initWithArray:localImageListArray copyItems:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 200000;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *urlString;
    //    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (WB_UserService.currentUser.isCloudLogin) {
        
    }else{
        urlString = [NSString stringWithFormat:@"%@boxes/%@/tweets",[JYRequestConfig sharedConfig].baseURL,boxuuid];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
    }
    
    NSMutableDictionary *dataMutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
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
    NSData *josnData = [NSJSONSerialization dataWithJSONObject:dataMutableDic options:NSJSONWritingPrettyPrinted error:nil];
//    if (localImageListArray.count>0) {
//        [localDataArray enumerateObjectsUsingBlock:^(NSMutableDictionary *mutableDic, NSUInteger idx, BOOL * _Nonnull stop1) {
////            AFHTTPSessionManager *manager1 = [AFHTTPSessionManager manager];
////            manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
////            manager1.requestSerializer.timeoutInterval = 200000;
////            manager1.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
////
////            [manager1.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
////            NSLog(@"🌶%@",localDataArray);
//            NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
////                [formData appendPartWithFormData:josnData name:@"list"];
//
//
//                if (formdataError) {
//                    *stop1 = YES;
//                    callback(formdataError);
//                }
//
//            } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                NSLog(@"%@",responseObject);
////                callback(nil);
//            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSLog(@"%@",error);
////                callback(error);
//            }];
//              [dataTask resume];
//        }];
//    }else{
//        NSString *urlString;
//        //    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
//        if (WB_UserService.currentUser.isCloudLogin) {
//
//        }else{
//            urlString = [NSString stringWithFormat:@"%@boxes/%@/tweets",[JYRequestConfig sharedConfig].baseURL,boxuuid];
//
//            [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@ %@", WB_UserService.currentUser.boxToken,WB_UserService.defaultToken] forHTTPHeaderField:@"Authorization"];
//        }
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFormData:josnData name:@"list"];
        if (localImageListArray.count>0) {
            [localDataArray enumerateObjectsUsingBlock:^(NSMutableDictionary *mutableDic, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                [dic setObject:[mutableDic objectForKey:@"size"]  forKey:@"size"];
                [dic setObject:[mutableDic objectForKey:@"sha256"]  forKey:@"sha256"];
                NSString *filePath =[mutableDic objectForKey:@"filePath"];
                NSError *formdataError;
                NSData *jsonFileNameData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString =  [[NSString alloc] initWithData:jsonFileNameData  encoding:NSUTF8StringEncoding];
                NSLog(@"%@",filePath);
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"" fileName:jsonString mimeType:@"application/octet-stream" error:&formdataError];
            }];
        }
        

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        WBTweetModel *model = [WBTweetModel modelWithJSON:responseObject];
         NSLog(@"%@",model.uuid);
        
        callback(model,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        callback(nil,error);
    }];
    [dataTask resume];
//    }
    
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
