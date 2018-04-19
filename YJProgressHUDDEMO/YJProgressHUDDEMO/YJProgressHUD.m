//
//  YJProgressHUD.m
//  YJProgressHUDDEMO
//
//  Created by cool on 2018/4/19.
//  Copyright © 2018年 cool. All rights reserved.
//

#import "YJProgressHUD.h"

#define RV (UIView *)UIApplication.sharedApplication.keyWindow.subviews.firstObject

static NSMutableArray<UIWindow *> *windows;
static dispatch_source_t timer;
static NSInteger timerTimes = 0;
static NSInteger sn_topBar = 1001;

@implementation YJProgressHUD

/// 屏幕的旋转度数
+ (double)degree {
    NSArray<NSNumber *> *array = @[@0, @0, @180, @270, @90];
    return array[UIApplication.sharedApplication.statusBarOrientation].doubleValue;
}

+ (CGPoint)getRealCenter {
    if (UIApplication.sharedApplication.statusBarOrientation >= 3) {
        return CGPointMake([RV center].y, [RV center].x);
    }
    return [RV center];
}

+ (void)clear {
    [self cancelPreviousPerformRequestsWithTarget:self];
    
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
        timerTimes = 0;
    }
    
    [windows removeAllObjects];
}

+ (UIWindow *)showNoticeOnStatusBar:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSInteger)autoClearTime {
    CGRect frame = UIApplication.sharedApplication.statusBarFrame;
    
    UIWindow *window = [[UIWindow alloc] init];
    window.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:0x6a/0x100 green:0xb4/0x100 blue:0x9f/0x100 alpha:1];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = frame.size.height > 20 ? CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - 17, frame.size.width, 20) : frame;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    [view addSubview:label];
    
    window.frame = frame;
    view.frame = frame;
    
    if (UIDevice.currentDevice.systemVersion.floatValue < 9.0) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        if (screenWidth > screenHeight) {
            screenHeight = screenWidth + screenHeight;
            screenWidth = screenHeight - screenWidth;
            screenHeight = screenHeight - screenWidth;
        }
        
        NSArray<NSNumber *> *xArray = @[@0, @(screenWidth/2), @(screenWidth/2), @10, @(screenWidth-10)];
        CGFloat x = xArray[UIApplication.sharedApplication.statusBarOrientation].floatValue;
        
        NSArray<NSNumber *> *yArray = @[@0, @(10), @(screenHeight-10), @(screenHeight/2), @(screenHeight/2)];
        CGFloat y = yArray[UIApplication.sharedApplication.statusBarOrientation].floatValue;
        
        window.center = CGPointMake(x, y);
        // 改变方向
        window.transform = CGAffineTransformMakeRotation([self degree] * M_PI / 180);
    }
    window.windowLevel = UIWindowLevelStatusBar;
    window.hidden = NO;
    [window addSubview:view];
    [windows addObject:window];
    
    CGPoint origPoint = view.frame.origin;
    origPoint.y = -(view.frame.size.height);
    
    CGPoint destPoint = view.frame.origin;
    view.tag = sn_topBar;
    view.frame = CGRectMake(origPoint.x, origPoint.y, view.frame.size.width, view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        view.frame = CGRectMake(destPoint.x, destPoint.y, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL finished) {
        if (autoClear == YES) {
            [self performSelector:@selector(hideNotice:) withObject:window afterDelay:autoClearTime];
        }
    }];
    return window;
}

+ (UIWindow *)showWait:(NSArray<UIImage *> *)images timeInterval:(NSTimeInterval)timeInterval {
    
    CGRect frame = CGRectMake(0, 0, 78, 78);
    
    UIWindow *window = [[UIWindow alloc] init];
    window.backgroundColor = [UIColor redColor];
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 12;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    if (images.count <= 0) {
        UIActivityIndicatorView *AI = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        AI.frame = CGRectMake(21, 21, 36, 36);
        [AI startAnimating];
        [view addSubview:AI];
    } else {
        if (images.count > timerTimes) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.image = images.firstObject;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:imageView];
            
            
            timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, ^{
                imageView.image = images[timerTimes % images.count];
                timerTimes += 1;
            });
            dispatch_resume(timer);
        }
    }
    
    window.frame = frame;
    view.frame = frame;
    window.center = [RV center];
    
    if (UIDevice.currentDevice.systemVersion.floatValue < 9.0) {
        window.center = [self getRealCenter];
        window.transform = CGAffineTransformMakeRotation([self degree] * M_PI / 180);
    }
    
    window.windowLevel = UIWindowLevelNormal;
    window.hidden = NO;
    [window addSubview:view];
    window.hidden = NO;
    [windows addObject:window];
    
    view.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    }];
    
    [self performSelector:@selector(hideNotice:) withObject:window afterDelay:CGFLOAT_MAX];
    
    return window;
}

+ (UIWindow *)showText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSInteger)autoClearTime {
    
    UIWindow *window = [[UIWindow alloc] init];
    window.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 12;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    CGSize size = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 82, CGFLOAT_MAX)];
    label.bounds = CGRectMake(0, 0, size.width, size.height);
    [view addSubview:label];
    
    CGRect superFrame = CGRectMake(0, 0, label.frame.size.width + 50, label.frame.size.height + 30);
    window.frame = superFrame;
    view.frame = superFrame;
    
    label.center = view.center;
    window.center = [RV center];
    
    if (UIDevice.currentDevice.systemVersion.floatValue < 9.0) {
        window.center = [self getRealCenter];
        window.transform = CGAffineTransformMakeRotation([self degree] * M_PI / 180);
    }
    
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = NO;
    [window addSubview:view];
    
    [windows addObject:window];
    
    if (autoClear == YES) {
        [self performSelector:@selector(hideNotice:) withObject:window afterDelay:autoClearTime];
    }
    
    return window;
}

+ (UIWindow *)showNoticeWithText:(NSString *)text type:(YJProgressHUDType)type autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime{
    CGRect frame = CGRectMake(0, 0, 90, 90);
    
    UIWindow *window = [[UIWindow alloc] init];
    window.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 10;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    UIImage *image;
    
    switch (type) {
        case YJProgressHUDTypeSuccess:
            image = [YJProgressHUD imageOfSuccess];
            break;
        case YJProgressHUDTypeError:
            image = [YJProgressHUD imageOfError];
            break;
        default:
            image = [YJProgressHUD imageOfInfo];
            break;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(27, 15, 36, 36);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 60, 90, 16);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    [view addSubview:label];
    
    window.frame = frame;
    view.frame = frame;
    window.center = [RV center];
    
    if (UIDevice.currentDevice.systemVersion.floatValue < 9.0) {
        window.center = [self getRealCenter];
        window.transform = CGAffineTransformMakeRotation([self degree] * M_PI / 180);
    }
    
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = NO;
    window.center = [RV center];
    [window addSubview:view];
    [windows addObject:window];
    
    view.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    }];
    
    if (autoClear == YES) {
        [self performSelector:@selector(hideNotice:) withObject:window afterDelay:autoClearTime];
    }
    
    return window;
}

+ (void)hideNotice:(id)sender {
    
    if (![sender isKindOfClass:[UIWindow class]]) {
        NSLog(@"类型不匹配");
        return;
    }
    
    UIWindow *window = (UIWindow *)sender;
    if (!window.subviews.firstObject) {
        NSLog(@"window下无子视图");
        return;
    }
    
    UIView *view = window.subviews.firstObject;
    [UIView animateWithDuration:0.2 animations:^{
        if (view.tag == sn_topBar) {
            view.frame = CGRectMake(0, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
        }
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [windows removeObject:window];
    }];
}

@end

@implementation YJProgressHUD(Image)
+ (UIImage *)imageOfSuccess {
    return [self drawImage:(YJProgressHUDTypeSuccess)];
}

+ (UIImage *)imageOfError {
    return [self drawImage:(YJProgressHUDTypeError)];
}

+ (UIImage *)imageOfInfo {
    return [self drawImage:(YJProgressHUDTypeInfo)];
}

+ (UIImage *)drawImage:(YJProgressHUDType)type {
    
    if ([self isExistAtPath:[self imagePathWithtype:(type)]]) {
        return [UIImage imageWithContentsOfFile:[self imagePathWithtype:(type)]];
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 36), NO, 0);
    [self draw:type];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:[self imagePathWithtype:(type)] atomically:YES];
    
    return image;
}

+ (void)draw:(YJProgressHUDType)type {
    UIBezierPath *checkmarkShapePath = [[UIBezierPath alloc] init];
    
    /// 绘制圆形
    [checkmarkShapePath moveToPoint:(CGPointMake(36, 18))];
    [checkmarkShapePath addArcWithCenter:(CGPointMake(18, 18)) radius:17.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [checkmarkShapePath closePath];
    
    switch (type) {
        case YJProgressHUDTypeSuccess:
            [checkmarkShapePath moveToPoint:(CGPointMake(10, 18))];
            [checkmarkShapePath addLineToPoint:CGPointMake(16, 24)];
            [checkmarkShapePath addLineToPoint:CGPointMake(27, 13)];
            [checkmarkShapePath moveToPoint:(CGPointMake(10, 18))];
            [checkmarkShapePath closePath];
            break;
        case YJProgressHUDTypeError:
            [checkmarkShapePath moveToPoint:(CGPointMake(10, 10))];
            [checkmarkShapePath addLineToPoint:CGPointMake(26, 26)];
            [checkmarkShapePath moveToPoint:(CGPointMake(10, 26))];
            [checkmarkShapePath addLineToPoint:CGPointMake(26, 10)];
            [checkmarkShapePath moveToPoint:(CGPointMake(10, 10))];
            [checkmarkShapePath closePath];
            break;
        case YJProgressHUDTypeInfo:
            [checkmarkShapePath moveToPoint:(CGPointMake(18, 6))];
            [checkmarkShapePath addLineToPoint:CGPointMake(18, 22)];
            [checkmarkShapePath moveToPoint:(CGPointMake(18, 6))];
            [checkmarkShapePath closePath];
            
            [[UIColor whiteColor] setStroke];
            [checkmarkShapePath stroke];
            
            
            UIBezierPath *checkmarkShapePath =[[UIBezierPath alloc] init];
            [checkmarkShapePath moveToPoint:(CGPointMake(18, 27))];
            [checkmarkShapePath addArcWithCenter:(CGPointMake(18, 27)) radius:1 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
            [checkmarkShapePath closePath];
            
            [[UIColor whiteColor] setFill];
            [checkmarkShapePath fill];
            break;
    }
    [[UIColor whiteColor] setStroke];
    [checkmarkShapePath stroke];
}

+ (NSString *)imagePathWithtype:(YJProgressHUDType)type {
    
    NSArray<NSString *> *array = @[@"success", @"error", @"info"];
    
    NSString *imageName = @"info.png";
    if (array.count > type) {
        imageName = [NSString stringWithFormat:@"%@.png",array[type]];
    }
    return [[self imageDir] stringByAppendingPathComponent:imageName];
}

/// 获取图片路径
+ (NSString *)imageDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *path = [documentPath stringByAppendingPathComponent:@"YJProgressHUD"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

// 判断文件是否存在
+ (BOOL)isExistAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    return isExist;
}

@end

@implementation UIWindow(YJProgressHUD)
- (void)hide {
    [YJProgressHUD hideNotice:self];
}
@end

@implementation UIResponder (YJHUD)

- (UIWindow *)showWait {
    return [YJProgressHUD showWait:nil timeInterval:0];
}
- (UIWindow *)showWaitWithImages:(NSArray<UIImage *> *)images timeInterval:(NSTimeInterval)timeInterval {
    return [YJProgressHUD showWait:images timeInterval:timeInterval];
}

- (UIWindow *)showNoticeTop:(NSString *)text {
    return [self showNoticeTopWithText:text autoClear:YES autoClearTime:2];
}
- (UIWindow *)showNoticeTopWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime {
    return [YJProgressHUD showNoticeOnStatusBar:text autoClear:autoClear autoClearTime:autoClearTime];
}

- (UIWindow *)showSuccess:(NSString *)text {
    return [self showSuccessWithText:text autoClear:YES autoClearTime:2];
}
- (UIWindow *)showSuccessWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime {
    return [YJProgressHUD showNoticeWithText:text type:(YJProgressHUDTypeSuccess) autoClear:autoClear autoClearTime:autoClearTime];
}

- (UIWindow *)showError:(NSString *)text {
    return [self showErrorWithText:text autoClear:YES autoClearTime:2];
}
- (UIWindow *)showErrorWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime {
    return [YJProgressHUD showNoticeWithText:text type:(YJProgressHUDTypeError) autoClear:autoClear autoClearTime:autoClearTime];
}

- (UIWindow *)showInfo:(NSString *)text {
    return [self showInfoWithText:text autoClear:YES autoClearTime:2];
}
- (UIWindow *)showInfoWithText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime {
    return [YJProgressHUD showNoticeWithText:text type:(YJProgressHUDTypeInfo) autoClear:autoClear autoClearTime:autoClearTime];
}

- (UIWindow *)showOnlyText:(NSString *)text {
    return [self showOnlyText:text autoClear:YES autoClearTime:2];
}
- (UIWindow *)showOnlyText:(NSString *)text autoClear:(BOOL)autoClear autoClearTime:(NSTimeInterval)autoClearTime {
    return [YJProgressHUD showText:text autoClear:autoClear autoClearTime:autoClearTime];
}

- (void)clearAllNotice {
    [YJProgressHUD clear];
}
@end
