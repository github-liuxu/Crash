//
//  CrashTextViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashTextViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import <MessageUI/MFMailComposeViewController.h>

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

- (UIView *)rightNavigationBarItemView {
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailButton setTitle:@"Email" forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.emailButton.frame = CGRectMake(0, 0, 44, 44);
    [self.emailButton addTarget:self action:@selector(rightNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.emailButton;
}

- (void)rightNavButtonClick:(UIButton *)button {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mfMail = [MFMailComposeViewController new];
        mfMail.mailComposeDelegate = self;
        if (self.emailAddress) {
            [mfMail setToRecipients:@[self.emailAddress]];
        }
        [mfMail setSubject:@"Crash"];
        [mfMail setMessageBody:@"Bug file!" isHTML:NO];
        
        NSData *log = [NSData dataWithContentsOfFile:self.crashPath];
        [mfMail addAttachmentData:log mimeType:@"log" fileName:[self.crashPath lastPathComponent]];
        
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:mfMail animated:YES completion:NULL];
    } else {
        if (self.emailFrom && self.emailAddress && self.login && self.pass) {
            SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
            testMsg.fromEmail = self.emailFrom;
            testMsg.toEmail = self.emailAddress;
            testMsg.relayHost = self.relayHost;
            testMsg.requiresAuth = YES;
            testMsg.login = self.login;
            testMsg.pass = self.pass;
            testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
            testMsg.subject = self.subject;
            testMsg.delegate = self;
            NSString *filePath = self.crashPath;
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            NSString *content = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            NSMutableArray *array = [NSMutableArray array];
            NSDictionary *plainPart = @{kSKPSMTPPartContentTypeKey : @"text/plain", kSKPSMTPPartMessageKey : content, kSKPSMTPPartContentTransferEncodingKey : @"8bit"};
            [array addObject:plainPart];
            
            NSString *keys = [NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"",filePath.lastPathComponent];
            NSString *attachment = [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"",filePath.lastPathComponent];
            NSDictionary *filePart = [NSDictionary dictionaryWithObjectsAndKeys:keys,kSKPSMTPPartContentTypeKey,
                                      attachment,kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
            [array addObject:filePart];

            testMsg.parts = array;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [testMsg send];
            });
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请配置邮箱" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:NULL];
        }
    }
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

#pragma - mark SKPSMTPMessage
-(void)messageSent:(SKPSMTPMessage *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发送成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:NULL];
}

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"发送失败" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:NULL];
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
