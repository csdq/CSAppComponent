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
    [CSNetworkTool.createInstance.url(@"https://umc.51yizhen.com/oa/yzwy/appUpdate.json").rac_request() subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
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
    
    NSString *result =  [CSDataTool aesEncrption:@"Only u saw what I did" key:@"123456"];
    NSLog(@"%@",result);
    NSLog(@"AES D Test : %@",[CSDataTool aesDecryption:result key:@"1"]);
    NSLog(@"AES D Test : %@",[CSDataTool aesDecryption:result key:@"123456"]);
    
    NSString *priKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_private_key" ofType:@"pem"];
    NSString *pubKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_public_key" ofType:@"pem"];
    NSString *priKey = [NSString stringWithContentsOfFile:priKeyPath encoding:NSASCIIStringEncoding error:nil];
    NSString *pubKey = [NSString stringWithContentsOfFile:pubKeyPath encoding:NSASCIIStringEncoding error:nil];
//    priKey = [[priKey substringWithRange:range] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    range = NSMakeRange(@"ssh-rsa ".length,pubKey.length - @"ssh-rsa ".length -@" mr.s@MBP".length);
//    pubKey = [[pubKey substringWithRange:range] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    result = [CSDataTool rsaEncryption:@"I also know" pubkey:pubKey];
    NSLog(@"RSA : %@\n\n%@", result,[CSDataTool rsaDecryption:result prikey:priKey]);
    result = [CSDataTool rsaEncryption:@"I also know" prikey:priKey];
    NSLog(@"RSA : %@\n\n%@", result,[CSDataTool rsaDecryption:result pubkey:pubKey]);
    
    
     CSFile *file = [CSFile new];
     file.source = [NSURL URLWithString:@"https://tse3.mm.bing.net/th?id=OIP.YQKrYCL2Rdl02XeZgKjGcgHaE7&pid=Api"];
    file.fileName = @"一张图片片.png";
     [CSFileManager downloadFile:file progress:^(CGFloat percent) {
         [ProgressHUD showSuccess:[NSString stringWithFormat:@"%.2f",percent]];
    } completed:^(CSFile *file) {
        NSLog(@"%@ %@ %@ %@",file.fileName,file.fileSizeText,file.creationDate,file.modicationDate);
        [CSFileManager deleteFile:file];
    } failed:^(NSError *error) {
        
    }];
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
