//
//  WBFilesAndTransmitProtocal.h
//  WisnucBox
//
//  Created by wisnuc-imac on 2017/12/1.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WBFilesAndTransmitProtocal <NSObject>

typedef enum
{
    FilesTypePNG = 0,
    FilesTypeGIF,
    FilesTypeJPG,
    FilesTypeMP4,
    FilesTypeMOV
} FilesType;
@end
