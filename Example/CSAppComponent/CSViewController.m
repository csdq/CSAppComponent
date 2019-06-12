//
//  CSViewController.m
//   CSAppComponent
//
//  Created by Mr.s on 03/21/2017.
//  Copyright (c) 2017 Mr.s. All rights reserved.
//

#import "CSViewController.h"
#import <CSAppComponent/CSAppComponent.h>
//#import <ProgressHUD/ProgressHUD.h>
#import <CSAppComponent/CSNavigationBar.h>
#import <Masonry/Masonry.h>

@interface CSViewController ()<UINavigationBarDelegate>

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view cs_showLoadStateInCenterOfView:self.view];
    self.title = @"测试";
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
