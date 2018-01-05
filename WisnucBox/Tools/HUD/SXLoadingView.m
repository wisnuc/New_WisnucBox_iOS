//
//  SXSubmitLoadingView.m
//  TPORoot
//
//  Created by SunX on 14-7-9.
//  Copyright (c) 2014年 SunX. All rights reserved.
//
#import "SXLoadingView.h"
#import "sys/utsname.h"
UIWindow *_mainWindow() {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    }
    else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return nil;
}


#import "MBProgressHUD.h"

static MBProgressHUD  *s_progressHUD = nil;

@implementation SXLoadingView


+ (void)showProgressHUD:(NSString *)aString duration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
        MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:_mainWindow()];
        [_mainWindow() addSubview:progressHUD];
        progressHUD.animationType = MBProgressHUDAnimationZoom;
        progressHUD.labelText = aString;
        
        progressHUD.removeFromSuperViewOnHide = YES;
        progressHUD.opacity = 0.7;
        [progressHUD show:NO];
        [progressHUD hide:YES afterDelay:duration];
    });
}

+ (void)showProgressHUDText:(NSString *)aString duration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
        MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:_mainWindow()];
        progressHUD.mode = MBProgressHUDModeText;
        progressHUD.labelText = aString;
        progressHUD.labelFont = [UIFont systemFontOfSize:13];
        [_mainWindow() addSubview:progressHUD];
        progressHUD.animationType = MBProgressHUDAnimationZoom;
        progressHUD.labelText = aString;
        
        progressHUD.removeFromSuperViewOnHide = YES;
        progressHUD.opacity = 0.7;
        [progressHUD show:NO];
        [progressHUD hide:YES afterDelay:duration];
    });
}


+ (void)showProgressHUD:(NSString *)aString {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!s_progressHUD) {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                s_progressHUD = [[MBProgressHUD alloc] initWithView:_mainWindow()];
            });
        }else{
            [s_progressHUD hide:NO];
        }
        [_mainWindow() addSubview:s_progressHUD];
        s_progressHUD.removeFromSuperViewOnHide = YES;
        s_progressHUD.animationType = MBProgressHUDAnimationZoom;
        s_progressHUD.dimBackground = YES;
//        s_progressHUD.
        if ([aString length]>0) {
            s_progressHUD.labelText = aString;
        }
        else s_progressHUD.labelText = nil;
        
        s_progressHUD.opacity = 0.7;
        [s_progressHUD show:YES];
        if (s_progressHUD) {
             [s_progressHUD hide:YES afterDelay:30];
        }
    });
    
    
}

+ (void)showAlertHUD:(NSString *)aString duration:(CGFloat)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
        MBProgressHUD *progressHUD = [[MBProgressHUD alloc] initWithView:_mainWindow()];
        [_mainWindow() addSubview:progressHUD];
        progressHUD.animationType = MBProgressHUDAnimationZoom;
        progressHUD.labelText =aString;
        progressHUD.removeFromSuperViewOnHide = YES;
        progressHUD.opacity = 0.7;
        progressHUD.mode = MBProgressHUDModeText;
        [progressHUD show:NO];
        [progressHUD hide:YES afterDelay:duration];
    });
}

+ (void)hideProgressHUD {
    if (s_progressHUD) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [s_progressHUD hide:YES];
            [s_progressHUD removeFromSuperview];
        });
    }
}

+ (void)updateProgressHUD:(NSString*)progress {
    if (s_progressHUD) {
        s_progressHUD.labelText = progress;
    }
}

+ (BOOL)isPregressing{
    if (s_progressHUD) {
        return YES;
    }else{
        return NO;
    }
}

@end
