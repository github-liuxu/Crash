//
//  ViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/10.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "CrashListViewController.h"
@import MessageUI;

@interface ViewController ()

@property (nonatomic, strong) NSArray *arrayP;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)crash:(id)sender {
    self.arrayP = @[];
    NSString *a = self.arrayP[0];
    NSLog(@"%@",a);
}
- (IBAction)show:(id)sender {
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"CrashStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    CrashListViewController *listVC = [st instantiateViewControllerWithIdentifier:@"CrashListViewController"];
    listVC.delegate = self;
//    listVC.emailAddress = @"xxxxx@xxx.com";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
