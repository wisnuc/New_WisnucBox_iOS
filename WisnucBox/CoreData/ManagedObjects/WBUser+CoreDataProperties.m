//
//  WBUser+CoreDataProperties.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUser+CoreDataProperties.h"

@implementation WBUser (CoreDataProperties)

+ (NSFetchRequest<WBUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WBUser"];
}

@dynamic userName;
@dynamic uuid;
@dynamic localToken;

@end
