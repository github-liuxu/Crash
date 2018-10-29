//
//  CrashListViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashListViewController.h"
#import "CrashTextViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface CrashListViewController ()<MFMailComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,SKPSMTPMessageDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *emailButton;

@end

@implementation CrashListViewController

- (instancetype)init {
    if (self = [super init]) {
        self.relayHost = @"smtp.163.com";
        self.subject = @"Crash Report";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"崩溃列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CrashCell"];
    self.dataSource = [NSMutableArray array];
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *crashPath = [document stringByAppendingPathComponent:@"CrashHandler"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *list = [fm contentsOfDirectoryAtPath:crashPath error:nil];
    for (NSString *crashFilePath in list) {
        [self.dataSource addObject:[crashPath stringByAppendingPathComponent:crashFilePath]];
    }
    NSEnumerator *enumerator = [self.dataSource reverseObjectEnumerator];
    self.dataSource = [NSMutableArray arrayWithArray:enumerator.allObjects];
    [self.tableView reloadData];
}

- (UIView *)leftNavigationBarItemView {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 44, 44);
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.backButton;
}

- (UIView *)rightNavigationBarItemView {
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailButton setTitle:@"Email" forState:UIControlStateNormal];
    [self.emailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.emailButton.frame = CGRectMake(0, 0, 44, 44);
    [self.emailButton addTarget:self action:@selector(rightNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.emailButton;
}

- (void)leftNavButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(backClick)]) {
        [self.delegate backClick];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)rightNavButtonClick:(UIButton *)button {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mfMail = [MFMailComposeViewController new];
        mfMail.mailComposeDelegate = self;
        if (self.emailAddress) {
            [mfMail setToRecipients:@[self.emailAddress]];
        }
        [mfMail setSubject:@"Crash"];
        [mfMail setMessageBody:@"Bug files!" isHTML:NO];
        
        for (int i = 0; i < self.dataSource.count; i++) {
            NSData *log = [NSData dataWithContentsOfFile:self.dataSource[i]];
            [mfMail addAttachmentData:log mimeType:@"log" fileName:[self.dataSource[i] lastPathComponent]];
        }
        
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
            if (testMsg.requiresAuth) {
                testMsg.login = self.login;
                testMsg.pass = self.pass;
            }
            testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
            testMsg.subject = self.subject;
            testMsg.delegate = self;
            NSString *content = [NSString stringWithCString:"Bug files!" encoding:NSUTF8StringEncoding];
            NSMutableArray *array = [NSMutableArray array];
            NSDictionary *plainPart = @{kSKPSMTPPartContentTypeKey : @"text/plain", kSKPSMTPPartMessageKey : content, kSKPSMTPPartContentTransferEncodingKey : @"8bit"};
            [array addObject:plainPart];
    
            for (int i = 0; i < self.dataSource.count; i++) {
                NSString *filePath = self.dataSource[i];
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                NSString *keys = [NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"",filePath.lastPathComponent];
                NSString *attachment = [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"",filePath.lastPathComponent];
                NSDictionary *filePart = [NSDictionary dictionaryWithObjectsAndKeys:keys,kSKPSMTPPartContentTypeKey,
                                         attachment,kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
                [array addObject:filePart];
            }
            
            
            
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CrashCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.dataSource[indexPath.row] lastPathComponent];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CrashTextViewController *ct = [CrashTextViewController new];
    ct.crashPath = self.dataSource[indexPath.row];
    ct.emailAddress = self.emailAddress;
    ct.emailFrom = self.emailFrom;
    ct.relayHost = self.relayHost;
    ct.subject = self.subject;
    ct.login = self.login;
    ct.pass = self.pass;
    [self.navigationController pushViewController:ct animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self.dataSource[indexPath.row] error:nil];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
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
