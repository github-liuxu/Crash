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

@end
