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
CS_PROPERTY_DECLARE(RACSubject, webSubject);
CS_LINKCODE_METHOD(CSWebViewController, NSString, loadURL)

CS_LINKCODE_METHOD(CSWebViewController, NSString, baseURL)
CS_LINKCODE_METHOD(CSWebViewController, NSString, loadHTML)
//CS_LINKCODE_METHOD_VOID(CSWebViewController, loadHTML)
@end
