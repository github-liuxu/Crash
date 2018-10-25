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

@interface CrashListViewController ()<MFMailComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

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
    MFMailComposeViewController *mfMail = [MFMailComposeViewController new];
    mfMail.mailComposeDelegate = self;
    if (self.emailAddress) {
        [mfMail setToRecipients:@[self.emailAddress]];
    }
    [mfMail setSubject:@"Crash"];
    [mfMail setMessageBody:[NSString stringWithContentsOfFile:self.dataSource.firstObject encoding:NSUTF8StringEncoding error:nil] isHTML:NO];
    
    NSData *log = [NSData dataWithContentsOfFile:self.dataSource.firstObject];
    [mfMail addAttachmentData:log mimeType:@"log" fileName:[self.dataSource.firstObject lastPathComponent]];
    
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:mfMail animated:YES completion:NULL];
    
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
    [self.navigationController pushViewController:ct animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
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
