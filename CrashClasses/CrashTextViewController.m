//
//  CrashTextViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashTextViewController.h"

@interface CrashTextViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CrashTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *text = [NSString stringWithContentsOfFile:self.crashPath encoding:NSUTF8StringEncoding error:nil];
    self.textView.text = text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
