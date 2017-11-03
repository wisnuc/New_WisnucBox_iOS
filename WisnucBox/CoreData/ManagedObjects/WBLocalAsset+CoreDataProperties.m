//
//  WBLocalAsset+CoreDataProperties.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBLocalAsset+CoreDataProperties.h"

@implementation WBLocalAsset (CoreDataProperties)

+ (NSFetchRequest<WBLocalAsset *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WBLocalAsset"];
}

@dynamic localId;
@dynamic digest;

@end
