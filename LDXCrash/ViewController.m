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
    self.arrayP = @[];
//    int j = 0;
//    int i = 1;
//    int b = i/j;
//    NSLog(@"%d",b);
//    NSString *a = self.arrayP[0];
//    NSLog(@"%@",a);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"CrashStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    CrashListViewController *listVC = [st instantiateViewControllerWithIdentifier:@"CrashListViewController"];
    listVC.delegate = self;
    listVC.emailAddress = @"liu_dongxu@cdv.com";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];

    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma - mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
