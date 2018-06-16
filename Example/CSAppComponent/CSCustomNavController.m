//
//  CSCustomNavController.m
//  CSAppComponent_Example
//
//  Created by Mr.s on 2017/4/12.
//  Copyright © 2017年 Mr.s. All rights reserved.
//

#import "CSCustomNavController.h"

@interface CSCustomNavController ()

@end

@implementation CSCustomNavController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)cs_setView{
    [super cs_setView];
    self.useCustomNavigationBar = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
