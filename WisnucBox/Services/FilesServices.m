//
//  FIlesServices.m
//  WisnucBox
//
//  Created by JackYang on 2017/11/3.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FilesServices.h"
#import "WBFile+CoreDataClass.h"

@implementation FilesServices

- (void)abort {
    
}

- (void)dealloc {
    NSLog(@"FilesServices dealloc");
}

- (void)deleteFileWithFileUUID:(NSString *)fileuuid{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ && fileUUID = %@", WB_UserService.currentUser.uuid, fileuuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fileUUID IN %@ AND uuid = %@", fileuuids, WB_UserService.currentUser.uuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (NSArray<WBFile *> *)findAll{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ ", WB_UserService.currentUser.uuid];
    return [WBFile MR_findAllWithPredicate:predicate];
}
@end
