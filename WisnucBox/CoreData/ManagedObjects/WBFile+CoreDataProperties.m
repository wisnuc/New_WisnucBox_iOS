//
//  WBFile+CoreDataProperties.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBFile+CoreDataProperties.h"

@implementation WBFile (CoreDataProperties)

+ (NSFetchRequest<WBFile *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WBFile"];
}

@dynamic uuid;
@dynamic timeDate;
@dynamic filePath;
@dynamic fileName;
@dynamic fileSize;
@dynamic downloadedFileSize;
@dynamic downloadURL;

//@dynamic fileUUID;

@end
