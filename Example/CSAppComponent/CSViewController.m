//
//  CSViewController.m
//   CSAppComponent
//
//  Created by Mr.s on 03/21/2017.
//  Copyright (c) 2017 Mr.s. All rights reserved.
//

#import "CSViewController.h"
#import <CSAppComponent/CSAppComponent.h>
#import <ProgressHUD/ProgressHUD.h>
#import <MJRefresh/MJRefresh.h>
#import <CSAppComponent/CSNavigationBar.h>
#import <Masonry/Masonry.h>

@interface CSViewController ()<UINavigationBarDelegate>

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"测试";
    [ProgressHUD show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.cs_navigationBar changeBackgroundAlpha:0.3];
        [ProgressHUD showSuccess:@"加载成功"];
    });
    NSLog(@"%@",[UIFont defaultFont]);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.cs_navigationBar.leftView = btn;
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [btn1 addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    self.cs_navigationBar.rightView = btn1;
//    [self.cs_navigationBar setBackBtnTitle:@"欢迎页面"];
    [self.cs_navigationBar changeBackgroundAlpha:1];
    ({
        UIView *mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor redColor];
        CS_ADD_MAIN_VIEW_AND_FULLFILL(mainView);
    });
    self.title = @"test";
    NSLog(@"%@",self.view.subviews);
}

- (void)change{
    [self.cs_navigationBar changeBackgroundAlpha:0.8];
}
- (void)cs_viewWillAppear:(BOOL)animated{
//    [self.cs_navigationBar changeBackgroundAlpha:0.1];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//     [self.cs_navigationBar changeBackgroundAlpha:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

@end
