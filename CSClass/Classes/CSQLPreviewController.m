//
//  CSQLPreviewController.m
//  OAVendors
//
//  Created by shitingquan on 16/8/17.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSQLPreviewController.h"

@interface CSQLPreviewController ()
{

}
@end

@implementation CSQLPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
//    @try {
        [super viewDidDisappear:animated];
//    } @catch (NSException *exception) {
//        NSLog(@"异常：%@",exception.name);
//    } @finally {
//
//    }
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
