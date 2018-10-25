//
//  CrashListViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashListViewController.h"
#import "CrashTextViewController.h"
@import MessageUI;

@interface CrashListViewController ()<MFMailComposeViewControllerDelegate,UIAppearance>

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIButton *emailButton;

@end

@implementation CrashListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"崩溃列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([MFMailComposeViewController canSendMail]) {
        self.emailButton.enabled = YES;
    } else {
        self.emailButton.enabled = NO;
    }
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
    }
}

- (void)rightNavButtonClick:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        MFMailComposeViewController *mfMail = [MFMailComposeViewController new];
        mfMail.mailComposeDelegate = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (self.emailAddress) {
            [mfMail setToRecipients:@[self.emailAddress]];
        }
        
        [mfMail setSubject:@"Crash"];
        [mfMail setMessageBody:@"Hello send the bugs email to me!" isHTML:NO];
        
        NSData *log = [NSData dataWithContentsOfFile:self.dataSource.firstObject];
        [mfMail addAttachmentData:log mimeType:@"log" fileName:@"logfile"];
        // Present the view controller modally.
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mfMail animated:YES completion:NULL];
    }];
    
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
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"CrashStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    CrashTextViewController *ct = [st instantiateViewControllerWithIdentifier:@"CrashTextViewController"];
    ct.crashPath = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:ct animated:YES];
}

#pragma - mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
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
