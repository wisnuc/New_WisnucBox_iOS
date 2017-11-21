//
//  FilesDataSourceManager.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/15.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FilesDataSourceManager;
@protocol FLDataSourceDelegate <NSObject>

-(void)datasource:(FilesDataSourceManager *)datasource finishLoading:(BOOL)finish;

@end
@interface FilesDataSourceManager : NSObject

@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic,weak) id<FLDataSourceDelegate> delegate;

+ (instancetype)manager;
+ (void)destroyAll;
- (void)getFilesWithDriveUUID:(NSString *)driveUUID DirUUID:(NSString *)uuid;

@end
