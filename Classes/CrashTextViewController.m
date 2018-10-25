//
//  CrashTextViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashTextViewController.h"
@import MessageUI;

@interface CrashTextViewController ()<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (nonatomic, strong) UIButton *emailButton;

@end

@implementation CrashTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.textView];
    NSString *text = [NSString stringWithContentsOfFile:self.crashPath encoding:NSUTF8StringEncoding error:nil];
    self.textView.text = text;
    self.textView.editable = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([MFMailComposeViewController canSendMail]) {
        self.emailButton.enabled = YES;
    } else {
        self.emailButton.enabled = NO;
    }
}

- (UIView *)rightNavigationBarItemView {
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailButton setTitle:@"Email" forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.emailButton.frame = CGRectMake(0, 0, 44, 44);
    [self.emailButton addTarget:self action:@selector(rightNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.emailButton;
}

- (void)rightNavButtonClick:(UIButton *)button {
    MFMailComposeViewController *mfMail = [MFMailComposeViewController new];
    mfMail.mailComposeDelegate = self;
    if (self.emailAddress) {
        [mfMail setToRecipients:@[self.emailAddress]];
    }
    [mfMail setSubject:@"Crash"];
    [mfMail setMessageBody:[NSString stringWithContentsOfFile:self.crashPath encoding:NSUTF8StringEncoding error:nil] isHTML:NO];
    
    NSData *log = [NSData dataWithContentsOfFile:self.crashPath];
    [mfMail addAttachmentData:log mimeType:@"log" fileName:[self.crashPath lastPathComponent]];
    
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:mfMail animated:YES completion:NULL];
    
}

#pragma - mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发送失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:NULL];
    }
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
