//
//  CrashListViewController.m
//  testCrash
//
//  Created by 刘东旭 on 2018/5/11.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "CrashListViewController.h"
#import "CrashTextViewController.h"

@interface CrashListViewController ()

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *backButton;

@end

@implementation CrashListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"崩溃列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
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

- (void)leftNavButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(backClick)]) {
        [self.delegate backClick];
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
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"CrashStoryboard" bundle:[NSBundle bundleForClass:self.class]];
    CrashTextViewController *ct = [st instantiateViewControllerWithIdentifier:@"CrashTextViewController"];
    ct.crashPath = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:ct animated:YES];
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
