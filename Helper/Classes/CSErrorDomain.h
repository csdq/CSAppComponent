//
//  CSErrorDomain.h
//   CSAppComponent
//
//  Created by temps on 2017/3/19.
//  Copyright © Mr.s. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString * CSErrorDomainName;

/***************************错误码*********************************/
//默认
extern const NSString * CSErrorCodeSuccess;
extern const NSString * CSErrorCodeFail;
//用户模块
extern const NSString * CSErrorCodeWrongNameOrPassword;

@interface CSErrorDomain : NSObject
+ (BOOL)isSuccess:(NSNumber *)code;
@end
