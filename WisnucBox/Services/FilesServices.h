//
//  FIlesServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBFile;
@interface FilesServices : NSObject <ServiceProtocol>

- (void)saveFile:(WBFile *)file;

- (BOOL)deleteFileWithFileUUID:(NSString *)fileuuid andUser:(NSString *)userId;

- (BOOL)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids andUser:(NSString *)userId;

@end
