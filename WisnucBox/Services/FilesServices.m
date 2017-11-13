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

- (void)saveFile:(WBFile *)file{
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ && fileUUID = %@", file.uuid, file.fileUUID];
//    WBFile * oldFile = [WBFile MR_findFirstWithPredicate:<#(nullable NSPredicate *)#>]
    WBFile * newFile = [WBFile MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    newFile.uuid = file.uuid;
//    newFile.fileUUID = file.fileUUID;
    newFile.fileName = file.fileName;
    newFile.filePath = file.filePath;
    newFile.timeDate = file.timeDate;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (BOOL)deleteFileWithFileUUID:(NSString *)fileuuid andUser:(NSString *)userId{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ && fileUUID = %@", userId, fileuuid];
    
    return [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (BOOL)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids andUser:(NSString *)userId {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fileUUID IN %@ AND uuid = %@", fileuuids, userId];
    return [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
@end
