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

- (void)deleteFileWithFileUUID:(NSString *)fileuuid FileName:(NSString *)fileName{
    
    [self removeFileWithFileName:fileName UUID:fileuuid];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ && fileUUID = %@", WB_UserService.currentUser.uuid, fileuuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fileUUID IN %@ AND uuid = %@", fileuuids, WB_UserService.currentUser.uuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)removeFileWithFileName:(NSString *)fileName UUID:(NSString *)uuid{
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
    NSString* suffixName = uuid;
    NSString *fileNameString = fileName;
    NSString *extensionstring = [fileNameString pathExtension];
    NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",suffixName,extensionstring]];
    NSLog(@"文件位置%@",saveFile);
    if ([[NSFileManager defaultManager] fileExistsAtPath:saveFile]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:saveFile error:&error];
        if (error) {
            NSLog(@"删除失败");
        }else{
            NSLog(@"删除成功");
        }
    }
}

- (long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        unsigned long long  size = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return size;
    }
    return 0;
}

- (NSArray<WBFile *> *)findAll{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ ", WB_UserService.currentUser.uuid];
    return [WBFile MR_findAllWithPredicate:predicate];
}
@end
