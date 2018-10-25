# Crash
崩溃日志收集

pod 'LDXCrash'

Appdelegate.m
[CrashUncaughtExceptionHandler installUncaughtExceptionHandler:YES];

    CrashListViewController *listVC = [CrashListViewController new];
    listVC.delegate = self;
//    listVC.emailAddress = @"xxxxx@xxx.com";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    
    [self presentViewController:nav animated:YES completion:NULL];

