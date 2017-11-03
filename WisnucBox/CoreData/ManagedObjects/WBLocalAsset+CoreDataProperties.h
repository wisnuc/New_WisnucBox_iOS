//
//  WBLocalAsset+CoreDataProperties.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "WBLocalAsset+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface WBLocalAsset (CoreDataProperties)

+ (NSFetchRequest<WBLocalAsset *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *localId;
@property (nullable, nonatomic, copy) NSString *digest;

@end

NS_ASSUME_NONNULL_END
