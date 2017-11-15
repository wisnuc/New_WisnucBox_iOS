//
//  WBUser+CoreDataProperties.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUser+CoreDataProperties.h"

@implementation WBUser (CoreDataProperties)

+ (NSFetchRequest<WBUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"WBUser"];
}

@dynamic localToken;
@dynamic userName;
@dynamic uuid;
@dynamic cloudToken;
@dynamic isFirstUser;
@dynamic isAdmin;
@dynamic stationId;
@dynamic localAddr;
@dynamic isCloudLogin;
@dynamic sn_address;
@dynamic bonjour_name;
@dynamic backUpInWWAN;
@dynamic autoBackUp;
@dynamic avaterURL;
@dynamic userHome;
@dynamic backUpDir;
@dynamic backUpBaseDir;
@dynamic guid;
@dynamic askForBackup;

@end
