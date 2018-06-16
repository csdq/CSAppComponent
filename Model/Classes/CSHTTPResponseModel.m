//
//  CSHTTPResponseModel.m
//   CSAppComponent
//
//  Created by temps on 2017/3/19.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSHTTPResponseModel.h"

@implementation CSHTTPResponseModel
- (NSString *)message{
    if(_message == nil){
        return @"No Message";
    }
    return _message;
}
@end
