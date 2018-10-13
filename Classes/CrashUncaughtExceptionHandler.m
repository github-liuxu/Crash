#import "CrashUncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <UIKit/UIKit.h>

static int s_fatal_signals[] = {
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGSEGV,
    SIGPIPE
};

static int s_fatal_signal_num = sizeof(s_fatal_signals) / sizeof(s_fatal_signals[0]);

NSString * const crashUncaughtExceptionHandlerSignalExceptionName = @"crash_UncaughtExceptionHandlerSignalExceptionName";
NSString * const crashUncaughtExceptionHandlerSignalKey = @"crash_UncaughtExceptionHandlerSignalKey";
NSString * const crashUncaughtExceptionHandlerAddressesKey = @"crash_UncaughtExceptionHandlerAddressesKey";

volatile int32_t crashUncaughtExceptionCount = 0;
const int32_t crashUncaughtExceptionMaximum = 20;

@implementation CrashUncaughtExceptionHandler

static void HandleException(NSException *exception){

    int32_t exceptionCount = OSAtomicIncrement32(&crashUncaughtExceptionCount);
    
    if (exceptionCount > crashUncaughtExceptionMaximum) {
        return;
    }

    //获取调用堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:crashUncaughtExceptionHandlerAddressesKey];

    //在主线程中，执行制定的方法, withObject是执行方法传入的参数
    [[[CrashUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:[exception name]
                             reason:[exception reason]
                           userInfo:userInfo]
     waitUntilDone:YES];
}

static void SignalHandler(int signal){
    int32_t exceptionCount = OSAtomicIncrement32(&crashUncaughtExceptionCount);
    if (exceptionCount > crashUncaughtExceptionMaximum) {
        return;
    }

    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [CrashUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:crashUncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:crashUncaughtExceptionHandlerSignalKey];

    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[CrashUncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:crashUncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
}

static NSString* getAppInfo() {

    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}

static NSString* logCrashInfoToLocal()
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *crashPath = [documentPath stringByAppendingPathComponent:@"CrashHandler"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:crashPath]){
        [fileManager createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    NSString *crashFileName = [currentDateString stringByAppendingString:@".log"];
    NSString *path = [crashPath stringByAppendingPathComponent:crashFileName];
    return path;
}

+ (void)installUncaughtExceptionHandler:(BOOL)install {
    //objective-c未捕获异常的捕获
    NSSetUncaughtExceptionHandler(install ? HandleException : NULL);
    
    //错误信号捕获
    for (int i = 0; i < s_fatal_signal_num; ++i) {
        signal(s_fatal_signals[i], install ? SignalHandler : SIG_DFL);
    }
}

//获取调用堆栈
+ (NSArray *)backtrace {
    
    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

//处理报错信息
- (void)saveCriticalApplicationData:(NSException *)exception {
    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    
    NSString* logPath = logCrashInfoToLocal();
    [exceptionInfo writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)handleException:(NSException *)exception {
    [self saveCriticalApplicationData:exception];
    if ([[exception name] isEqual:crashUncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:crashUncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}


@end

