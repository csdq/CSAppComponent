//
//  CSBaseViewController.m
//  CSAppComponent
//  Follow MVVM Pattern
//  Created by temps on 2017/3/13.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSBaseViewController.h"
#import "CSBaseSetting.h"
@interface CSBaseViewController ()

@end

@implementation CSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [CSBaseSetting settingModel].viewControllerBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}
//设置视图
- (void)cs_setView{
    
}
//设置数据模型／容器
- (void)cs_setModel{
    
}
//设置视图模型
- (void)cs_setViewModel{
    
}
@end
