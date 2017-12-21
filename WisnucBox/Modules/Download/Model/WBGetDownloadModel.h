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
@property (nonatomic) NSString *torrentPath;
@property (nonatomic) NSString *magnetURL;
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
@property (nonatomic) NSString *torrentPath;
@property (nonatomic) NSString *magnetURL;
@property (nonatomic) NSString *dirUUID;
@property (nonatomic) NSNumber *timeRemaining;
@property (nonatomic) NSNumber *downloaded;
@property (nonatomic) NSNumber *downloadSpeed;
@property (nonatomic) NSNumber *progress;
@property (nonatomic) NSNumber *numPeers;
@property (nonatomic) NSNumber *isPause;
@property (nonatomic) NSString *state;
//  "infoHash": "9049e20c0bc0074740355a469214cfa337621b1c",
//"timeRemaining": 22382792.83876772,
//"downloaded": 2785280,
//"downloadSpeed": 176947.2,
//"progress": 0.0007027576463818741,
//"numPeers": 19,
//"path": "/run/wisnuc/volumes/ac028211-c969-404f-b21e-ffbcca28f2d3/wisnuc/fruitmix/torrentTmp/c0dd8c1a-d4a2-4637-a7d7-b8b3938fb9ed",
//"name": "Operation.Dunkirk.2017.1080p.WEB-DL.DD5.1.H264-FGT",
//"torrentPath": "/home/liu/Documents/code/appifi/tmptest/upload_34995ee12189fb66ea9b3c807f983f6c.torrent",
//"magnetURL": null,
//"dirUUID": "b08076ff-f7dc-4c0c-a773-7c0d93e74dce","state": "downloading","userUUID": "c0dd8c1a-d4a2-4637-a7d7-b8b3938fb9ed","isPause": false
@end

@interface WBGetDownloadModel : NSObject
@property (nonatomic) NSArray *finish;
@property (nonatomic) NSArray *running;

@end
