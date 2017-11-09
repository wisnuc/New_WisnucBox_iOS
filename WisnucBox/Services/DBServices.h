//
//  DBServices.h
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBServices : NSObject<ServiceProtocol>

@property (nonatomic) dispatch_queue_t saveQueue;

@property (nonatomic) NSManagedObjectContext * saveContext;

-(NSManagedObjectContext *)createContext;

@end
