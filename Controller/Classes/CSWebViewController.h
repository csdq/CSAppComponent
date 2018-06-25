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
#import <WebKit/WKScriptMessage.h>

@interface CSWebViewController : CSBaseViewController
///js调用Cocoa
CS_PROPERTY_DECLARE(RACSubject, webSubject);
///Cocoa 调用js
CS_PROPERTY_DECLARE(RACCommand, webJSCmd);
///js调用结果
CS_PROPERTY_DECLARE(RACSubject, webJSResultSubject);
///加载URL 支持file http/https ftp
CS_LINKCODE_METHOD(CSWebViewController, NSURL, loadURL)
///基础URL
CS_LINKCODE_METHOD(CSWebViewController, NSURL, baseURL)
///加载html
CS_LINKCODE_METHOD(CSWebViewController, NSString, loadHTML)
@end
