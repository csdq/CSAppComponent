//
//  CSNavViewController.m
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSBaseNavViewController.h"
#import "CSNavigationBar.h"
#import <Masonry/Masonry.h>
#import "CSBaseSetting.h"

@interface CSBaseNavViewController ()<UINavigationControllerDelegate>
{
}
@end

@implementation CSBaseNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.effectType = CSNavTransEffectTypeMove;
    ///默认颜色 白色
    self.view.backgroundColor = [CSBaseSetting settingModel].viewControllerBackgroundColor;
    
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
    return UIInterfaceOrientationMaskPortrait;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUseCustomNavigationBar:(BOOL)useCustomNavigationBar{
    _useCustomNavigationBar = useCustomNavigationBar;
    self.navigationBarHidden = _useCustomNavigationBar;    
}

@end
