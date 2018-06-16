//
//  CSErrorDomain.m
//   CSAppComponent
//
//  Created by temps on 2017/3/19.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSErrorDomain.h"
NSString const * CSErrorDomainName = @"com.csdq";
NSString const * CSErrorCodeSuccess = @"CSErrorCodeSuccess";
NSString const * CSErrorCodeFail = @"CSErrorCodeFail";
NSString const * CSErrorCodeWrongNameOrPassword = @"CSErrorCodeWrongNameOrPassword";
static NSDictionary * cs_errorDict;
@implementation CSErrorDomain
+ (BOOL)isSuccess:(NSNumber *)code{
    if(code == nil){
        return NO;
    }
    return [[[self errorCodeDict] objectForKey:CSErrorCodeSuccess] isEqualToNumber:code];
}

+ (NSDictionary *)errorCodeDict{
    if(!cs_errorDict){
        cs_errorDict = @{
                         CSErrorCodeSuccess:@(200),
                         CSErrorCodeFail:@(0),
                         //
                         CSErrorCodeWrongNameOrPassword:@(500),
                         };
    }
    return cs_errorDict;
}
@end
