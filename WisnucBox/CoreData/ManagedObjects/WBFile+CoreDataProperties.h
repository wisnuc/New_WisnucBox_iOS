//
//  WBFile+CoreDataProperties.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBFile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WBFile (CoreDataProperties)

+ (NSFetchRequest<WBFile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSDate *timeDate;
@property (nullable, nonatomic, copy) NSString *filePath;
@property (nullable, nonatomic, copy) NSString *fileName;
//@property (nullable, nonatomic, copy) NSString *fileUUID;
@property (nullable, nonatomic, copy) NSNumber *fileSize;
@property (nullable, nonatomic, copy) NSNumber *downloadedFileSize;
@property (nullable, nonatomic, copy) NSString *downloadURL;

@end

NS_ASSUME_NONNULL_END
