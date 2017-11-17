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

- (void)deleteFileWithFileUUID:(NSString *)fileuuid;

- (void)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids;

- (NSArray<WBFile *> *)findAll;

- (long long)fileSizeAtPath:(NSString*) filePath;

@end
