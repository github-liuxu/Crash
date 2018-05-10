#import <Foundation/Foundation.h>

@interface CrashUncaughtExceptionHandler : NSObject

/*!
 *  异常的处理方法
 *
 *  @param install 是否开启捕获异常
 */
+ (void)installUncaughtExceptionHandler:(BOOL)install;

@end
