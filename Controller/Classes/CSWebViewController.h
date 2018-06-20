//
//  CSWebViewController.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/27.
//

#import "CSBaseViewController.h"
#import "CSHelper.h"
#import "CSLinkCode.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CSWebViewController : CSBaseViewController
///js调用Cocoa反馈
CS_PROPERTY_DECLARE(RACSubject, webSubject);
///加载URL 支持file http/https ftp
CS_LINKCODE_METHOD(CSWebViewController, NSURL, loadURL)
///基础URL
CS_LINKCODE_METHOD(CSWebViewController, NSURL, baseURL)
///加载html
CS_LINKCODE_METHOD(CSWebViewController, NSString, loadHTML)
@end
