//
//  WBGetDownloadModel.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/20.
//  Copyright © 2017年 JackYang. All rights reserved.
//

@interface WBGetDownloadFinishModel : NSObject
@property (nonatomic) NSString *infoHash;
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *ppgPath;
@property (nonatomic) NSString *ppgURL;
@property (nonatomic) NSString *dirUUID;
@property (nonatomic) NSNumber *timeRemaining;
@property (nonatomic) NSNumber *downloaded;
@property (nonatomic) NSNumber *downloadSpeed;
@property (nonatomic) NSNumber *progress;
@property (nonatomic) NSNumber *numPeers;
@property (nonatomic) NSNumber *isPause;
@property (nonatomic) NSString *state;
@property (nonatomic) NSNumber *finishTime;
@end

@interface WBGetDownloadRunnngModel : NSObject
@property (nonatomic) NSString *infoHash;
@property (nonatomic) NSString *path;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *ppgPath;
@property (nonatomic) NSString *ppgURL;
@property (nonatomic) NSString *dirUUID;
@property (nonatomic) NSNumber *timeRemaining;
@property (nonatomic) NSNumber *downloaded;
@property (nonatomic) NSNumber *downloadSpeed;
@property (nonatomic) NSNumber *progress;
@property (nonatomic) NSNumber *numPeers;
@property (nonatomic) NSNumber *isPause;
@property (nonatomic) NSString *state;

@end

@interface WBGetDownloadModel : NSObject
@property (nonatomic) NSArray *finish;
@property (nonatomic) NSArray *running;

@end
