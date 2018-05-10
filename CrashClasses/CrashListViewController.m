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

@end

@implementation CrashListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
