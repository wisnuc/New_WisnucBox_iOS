//
//  CSFileUtil.m
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/11/13.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "CSFileUtil.h"

@implementation CSFileUtil
+ (unsigned long long)fileSizeForPath:(NSString*)path
{
    unsigned long long fileSize = 0;
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError* error = nil;
        NSDictionary* fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    
    return fileSize;
}

+ (NSString*)tempPathFor:(NSString*)path saveIn:(NSString *)saveIn
{
    NSString* tempFilePath = nil;
    
    NSString* tempFileName = [path lastPathComponent];
    
    tempFilePath = [[CSFileUtil getPathInCacheDirBy:saveIn createIfNotExist:YES] stringByAppendingPathComponent:tempFileName];
    
    return tempFilePath;
}

+ (NSString*)getPathInDocumentsDirBy:(NSString*)subFolder createIfNotExist:(BOOL)needCeate
{
    NSString* subPath;
    
    NSString* dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    subPath = [dir stringByAppendingPathComponent:subFolder];
    
    if (![CSFileUtil fileExistsAtPath:subPath])
    {
        if (needCeate)
        {
            NSError* error = nil;
            if (![[NSFileManager new] createDirectoryAtPath:subPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"创建%@失败,Error=%@", subFolder,error);
            }
        }
    }
    
    return subPath;
}

+ (NSString*)getPathInCacheDirBy:(NSString*)subFolder createIfNotExist:(BOOL)needCeate
{
    
    NSString* subPath;
    
    NSString* dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Cache"];
    subPath = [dir stringByAppendingPathComponent:subFolder];
    
    if (![CSFileUtil fileExistsAtPath:subPath])
    {
        
        if (needCeate)
        {
            NSError* error = nil;
            if (![[NSFileManager new] createDirectoryAtPath:subPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"创建%@失败,Error=%@", subFolder,error);
            }
        }
    }
    
    return subPath;
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isExist = [fileManager fileExistsAtPath:path];
    
    // NSLog(@"fileExistsAtPath:%@ = %@",path, (isExist ? @"YES" : @"NO"));
    
    return isExist;
    
}

+ (BOOL)deleteFileAtPath:(NSString *)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    BOOL result = NO;
    
    if ([CSFileUtil fileExistsAtPath:path])
    {
        result = [fileManager removeItemAtPath:path error:&error];
    }
    else
    {
        result = YES;
    }
    
    if (error)
    {
        NSLog(@"removeItemAtPath:%@ 失败,error = %@",path,error);
    }
    else
    {
        NSLog(@"removeItemAtPath:%@ 成功,error = %@",path,error);
    }
    
    return result;
}

+ (BOOL) cutFileAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSError* error = nil;
    BOOL result = NO;
    
    if ([CSFileUtil deleteFileAtPath:dstPath])
    {
        
        if ([CSFileUtil fileExistsAtPath:srcPath])
        {
            result = [fileManager moveItemAtPath:srcPath toPath:dstPath error:&error];
        }
        
    }
    
    if (error)
    {
        // NSLog(@"moveItemAtPath:%@ toPath:%@ 失败,error = %@",srcPath,dstPath,error);
    }
    else
    {
        // NSLog(@"moveItemAtPath:%@ toPath:%@ 成功,error = %@",srcPath,dstPath,error);
    }
    
    return result;
}

+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(10, 9))
        return (float) (contentLength / (float)pow(10, 9));
    else if(contentLength >= pow(10, 6))
        return (float) (contentLength / (float)pow(10, 6));
    else if(contentLength >= pow(10, 3))
        return (float) (contentLength / (float)pow(10, 3));
    else
        return (float) (contentLength);
}
+ (NSString *)calculateUnit:(unsigned long long)contentLength
{
    unsigned long long size =contentLength;
    NSString *sizeText = nil;
    if (contentLength >= pow(10, 9)) { // size >= 1GB
        sizeText = [NSString stringWithFormat:@"%.2fG", size / pow(10, 9)];
    } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
        sizeText = [NSString stringWithFormat:@"%.2fM", size / pow(10, 6)];
    } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
        sizeText = [NSString stringWithFormat:@"%.2fK", size / pow(10, 3)];
    } else { // 1KB > size
        sizeText = [NSString stringWithFormat:@"%zdB", size];
    }
    return sizeText;
}

@end
