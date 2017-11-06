//
//  WBUser+CoreDataProperties.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/6.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WBUser (CoreDataProperties)

+ (NSFetchRequest<WBUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *localToken;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *cloudToken;
@property (nonatomic) BOOL isFirstUser;
@property (nonatomic) BOOL isAdmin;

@end

NS_ASSUME_NONNULL_END
