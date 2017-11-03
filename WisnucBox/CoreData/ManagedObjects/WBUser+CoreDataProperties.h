//
//  WBUser+CoreDataProperties.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WBUser (CoreDataProperties)

+ (NSFetchRequest<WBUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *uuid;

@end

NS_ASSUME_NONNULL_END
