//
//  CrashListViewController.h
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CrashListViewControllerDelegate

- (void)backClick;

@end

@interface CrashListViewController : UITableViewController

@property (nonatomic, weak) id delegate;


@property (nonatomic, strong) NSString *emailAddress;
/**
 静默发送需要配置
 */
@property (nonatomic, strong) NSString *emailFrom;
@property (nonatomic, strong) NSString *relayHost; //默认为 smtp.163.com
@property (nonatomic, strong) NSString *subject;   //邮件主题，没有的话被会认为是垃圾邮件
@property(nonatomic, strong) NSString *login;
@property(nonatomic, strong) NSString *pass;

@end
  
//  [CrashUncaughtExceptionHandler installUncaughtExceptionHandler:YES];
  
//   CrashListViewController *listVC = [CrashListViewController new];
//   listVC.delegate = self;
//   listVC.emailAddress = @"xxxxx@xxx.com";
//   UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC]; 
//   [self presentViewController:nav animated:YES completion:NULL];
