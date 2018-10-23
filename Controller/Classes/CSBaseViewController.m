//
//  CSBaseViewController.m
//  CSAppComponent
//  Follow MVVM Pattern
//  Created by temps on 2017/3/13.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSBaseViewController.h"
#import "CSBaseSetting.h"
#import "CSBaseNavViewController.h"
@interface CSBaseViewController ()

@end

@implementation CSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [CSBaseSetting settingModel].viewControllerBackgroundColor;
}
//设置数据模型／容器
- (void)cs_setModel{
    
}
//设置视图模型
- (void)cs_setViewModel{
    
}
//添加主视图
- (void)cs_addMainView:(UIView *)mainView{
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainView];
    if (@available(iOS 11,*)){
        [NSLayoutConstraint activateConstraints:
         @[
           [mainView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
           [mainView.rightAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.rightAnchor],
           [mainView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
           [mainView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor],
           ]];
    }else{
        id<UILayoutSupport> top = self.topLayoutGuide;
        id<UILayoutSupport> bottom = self.bottomLayoutGuide;
        if(self.cs_navigationBar.superview||([self.navigationController isKindOfClass:[CSNavViewController class]]&&((CSBaseNavViewController *)self.navigationController).useCustomNavigationBar)){
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-44-[mainView]-0-[bottom]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView,top,bottom)]];
        }else{
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-0-[mainView]-0-[bottom]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView,top,bottom)]];
        }
    }
}
@end
