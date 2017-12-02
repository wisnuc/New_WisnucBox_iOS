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

- (void)deleteFileWithFileUUID:(NSString *)fileuuid FileName:(NSString *)fileName ActionType:(NSString *)actionType{
    [self removeFileWithFileName:fileName UUID:fileuuid ActionType:actionType];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid = %@ && fileUUID = %@", WB_UserService.currentUser.uuid, fileuuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)deleteFilesWithFileUUIDs:(NSArray<NSString *> *)fileuuids{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"fileUUID IN %@ AND uuid = %@", fileuuids, WB_UserService.currentUser.uuid];
    [WBFile MR_deleteAllMatchingPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)removeFileWithFileName:(NSString *)fileName UUID:(NSString *)uuid ActionType:(NSString *)actionType{
    NSString *deletePath ;
    NSString* savePath = [CSFileUtil getPathInDocumentsDirBy:@"Downloads/" createIfNotExist:NO];
    NSString* suffixName = uuid;
    NSString *fileNameString = fileName;
    if (actionType && [actionType isEqualToString:@"上传"]) {
        NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
        deletePath = saveFile;
    }else{
        NSString *extensionstring = [fileNameString pathExtension];
        NSString* saveFile = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",suffixName,extensionstring]];
        deletePath = saveFile;
    }
   
    NSLog(@"文件位置%@",deletePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:deletePath]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:deletePath error:&error];
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
