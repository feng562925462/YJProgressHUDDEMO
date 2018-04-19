//
//  YJProgressHUD.h
//  YJProgressHUDDEMO
//
//  Created by cool on 2018/4/19.
//  Copyright © 2018年 cool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    YJProgressHUDTypeSuccess,
    YJProgressHUDTypeError,
    YJProgressHUDTypeInfo,
} YJProgressHUDType;

@interface YJProgressHUD : NSObject

+ (UIWindow *)showNoticeOnStatusBar:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSInteger)autoClearTime;
+ (UIWindow *)showWait:(NSArray<UIImage *> *)images timeInterval:(NSTimeInterval)timeInterval;
+ (UIWindow *)showText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSInteger)autoClearTime;
+ (UIWindow *)showNoticeWithText:(NSString *)text type:(YJProgressHUDType)type autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;
+ (void)clear;
@end

@interface YJProgressHUD(Image)

+ (UIImage *)imageOfSuccess;
+ (UIImage *)imageOfError;
+ (UIImage *)imageOfInfo;
+ (UIImage *)drawImage:(YJProgressHUDType)type;
@end

@interface UIWindow(YJProgressHUD)

- (void)hide;
@end

@interface UIResponder(YJProgressHUD)

- (UIWindow *)showWait;
- (UIWindow *)showWaitWithImages:(NSArray<UIImage *> *)images timeInterval:(NSTimeInterval)timeInterval;

- (UIWindow *)showNoticeTop:(NSString *)text;
- (UIWindow *)showNoticeTopWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;

- (UIWindow *)showSuccess:(NSString *)text;
- (UIWindow *)showSuccessWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;

- (UIWindow *)showError:(NSString *)text;
- (UIWindow *)showErrorWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;

- (UIWindow *)showInfo:(NSString *)text;
- (UIWindow *)showInfoWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;

- (UIWindow *)showOnlyText:(NSString *)text;
- (UIWindow *)showOnlyText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime;

- (void)clearAllNotice;
@end
