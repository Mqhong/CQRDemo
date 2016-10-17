//
//  HomeVC.m
//  二维码功能实现
//
//  Created by mm on 2016/10/17.
//  Copyright © 2016年 mm. All rights reserved.
//

#import "HomeVC.h"
#import "ViewController.h"
#import "CreatQRCode.h"
@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableview;
@property(nonatomic,strong) NSArray *arr;
@end

@implementation HomeVC

-(NSArray *)arr{
    if (_arr == nil) {
        _arr = @[@"生成二维码",@"扫描二维码"];
    }
    return _arr;
}

-(UITableView *)tableview{
    if (_tableview == nil) {
        _tableview = [[UITableView alloc] init];
        _tableview.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableview];
    self.navigationItem.title = @"二维码";
}

#pragma mark - UITableDatasource & UITableDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ddd"];
    cell.textLabel.text = self.arr[indexPath.row];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.row == 0) {
        NSLog(@"生成二维码");
        CreatQRCode *cQR = [[CreatQRCode alloc] init];
        [self.navigationController pushViewController:cQR animated:YES];
    }else if (indexPath.row == 1){
        NSLog(@"扫描二维码");
        ViewController *vc = [[ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
