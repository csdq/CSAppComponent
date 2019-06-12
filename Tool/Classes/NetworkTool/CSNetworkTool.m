//
//  CSNetworkTool.m
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSNetworkTool.h"
#import "AFNetworking.h"
#import "CSHTTPCommonResponseModel.h"
#import "CSErrorDomain.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

NSString *K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML = @"K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML";
@implementation CSRequestPage
+ (instancetype)page{
    return [self pageWith:1 size:20];
}

+ (instancetype)pageWith:(NSInteger)index size:(NSInteger)size{
    return [[CSRequestPage alloc] initWithIndex:index size:size];
}

- (instancetype)initWithIndex:(NSInteger)index size:(NSInteger)size{
    self = [super init];
    if (self) {
        self.pageSize = @(size);
        self.pageIndex = @(index);
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageSize = @(20);
        self.pageIndex = @(1);
    }
    return self;
}

- (void)setState:(CSDataState)state{
    _state = state;
    switch (state) {
        case CSDataStateError:
            [self subtract];
            break;
        case CSDataStateNomore:
            [self subtract];
            break;
        case CSDataStateNormal:
        default:
            break;
    }
}

- (instancetype)add{
    @synchronized(self){
        self.pageIndex = @([_pageIndex integerValue] + 1);
    }
    return self;
}

- (instancetype)subtract{
    @synchronized(self){
        self.pageIndex = @(MAX(0,[_pageIndex integerValue] - 1));
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@\nindex:%@ size:%@",[super description],_pageIndex,_pageSize];
}

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@\nindex:%@ size:%@",[super description],_pageIndex,_pageSize];
}
@end


@interface CSNetworkTool()
CS_PROPERTY_BLOCK_DECLARE(CSHttpRequestCommonBlock, successBlock)
CS_PROPERTY_BLOCK_DECLARE(CSHttpRequestCommonBlock, failBlock)
CS_PROPERTY_BLOCK_DECLARE(CSHttpRequestCommonBlock, progressBlock)
@end

@implementation CSNetworkTool
- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestTimeout = 60;
    }
    return self;
}

+ (instancetype)shared{
    return [self createInstance];
}

+ (instancetype)createInstance{
    CSNetworkTool * tool = [CSNetworkTool new];
    //JSON Default
    tool.responseFormat = CSResponseFormatJSON;
    return tool;
}

+ (NSString *)getIPv4Address{
    NSString *address_wifi = @"";
    NSString *address_cellular = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]){
                    address_wifi = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"] ) {
                    address_cellular = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address_wifi.length>0?address_wifi:address_cellular;
}

- (NSString *)identifier{
    if(_identifier == nil){
        _identifier = self->_url;
    }
    return _identifier;
}

- (void)dealloc{
    
}
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        _resultSubject = [RACSubject subject];
//    }
//    return self;
//}

- (RACSubject *)resultSubject{
    if(!_resultSubject){
        _resultSubject = [RACSubject subject];
        [_resultSubject setName:@" default network result subject"];
    }
    return _resultSubject;
}

//MARK: 请求方法执行
- (void)beginRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = self.requestTimeout;
    switch (self.responseFormat) {
        case CSResponseFormatJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case CSResponseFormatXML:
            manager.responseSerializer= [AFXMLParserResponseSerializer serializer];
            break;
        case CSResponseFormatPlain:
        default:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer.HTTPRequestHeaders setValue:@"no-store" forKey:@"Cache-Control"];
    NSLog(@"CSHTTP REQUEST\n%@%@",_url,_argument);
    switch (self.httpMethod) {
        case CSHttpMethodPost:
        {
            self.currentTask = [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
                if(self.progressBlock){
                    self.progressBlock(uploadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"CSHTTP RESPONSE\n%@",({NSMutableDictionary * mDict = [responseObject mutableCopy];
                    [mDict setObject:@"trace..." forKey:@"trace"];
                    mDict;
                }));
                if(self.successBlock){
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.iSuccess = YES;
                    model.responseObject = responseObject;
                    self.successBlock(model);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if(self.failBlock){
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.iSuccess = NO;
                    model.responseObject = error;
                    self.failBlock(model);
                }
            }];
        }
            break;
        case CSHttpMethodGet:
        default:
            self.currentTask = [manager GET:_url parameters:_argument progress:^(NSProgress * _Nonnull downloadProgress) {
                if(self.progressBlock){
                    self.progressBlock(downloadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if(self.successBlock){
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.iSuccess = YES;
                    model.responseObject = responseObject;
                    self.successBlock(model);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if(self.failBlock){
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.iSuccess = NO;
                    model.responseObject = error;
                    self.failBlock(model);
                }
            }];
            break;
    }
}
// CSRequest
//MARK: 请求方法执行
- (NSURLSessionDataTask *)cs_request_post{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = self.requestTimeout;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    switch (self.responseFormat) {
        case CSResponseFormatJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case CSResponseFormatXML:
            manager.responseSerializer= [AFXMLParserResponseSerializer serializer];
            break;
        case CSResponseFormatPlain:
        default:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
//    [manager.requestSerializer.HTTPRequestHeaders setValue:@"no-store" forKey:@"Cache-Control"];
//    manager.securityPolicy.allowInvalidCertificates = YES;
    NSLog(@"CSHTTP REQUEST\n%@%@",_url,_argument);
    return [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
        if(self.progressBlock){
            self.progressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",({
            NSMutableDictionary * mDict = nil;
            if([responseObject isKindOfClass:[NSDictionary class]]){
                mDict = [responseObject mutableCopy];
                [mDict setObject:@"trace..." forKey:@"trace"];
            }
            mDict;
        }));
        if(self.successBlock){
            CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
            model.task = task;
            model.iSuccess = YES;
            model.responseObject = responseObject;
            self.successBlock(model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CSHTTP ERROR\n%@",error);
        if(self.failBlock){
            CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
            model.task = task;
            model.iSuccess = NO;
            model.error = error;
            self.failBlock(model);
        }
    }];
}

- (NSURLSessionDataTask *)cs_request_get{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = self.requestTimeout;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    switch (self.responseFormat) {
        case CSResponseFormatJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case CSResponseFormatXML:
            manager.responseSerializer= [AFXMLParserResponseSerializer serializer];
            break;
        case CSResponseFormatPlain:
        default:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
    return [manager GET:_url parameters:_argument progress:^(NSProgress * _Nonnull downloadProgress) {
        if(self.progressBlock){
            self.progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",({NSMutableDictionary * mDict = [responseObject mutableCopy];
            [mDict setObject:@"trace..." forKey:@"trace"];
            mDict;
        }));
        if(self.successBlock){
            CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
            model.task = task;
            model.iSuccess = YES;
            model.responseObject = responseObject;
            self.successBlock(model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CSHTTP ERROR\n%@",error);
        if(self.failBlock){
            CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
            model.task = task;
            model.iSuccess = NO;
            model.error = error;
            self.failBlock(model);
        }
    }];
}

- (void)cancelRequest{
    [self.currentTask cancel];
}

CS_PROPERTY_INIT_CODE(NSMutableURLRequest, request, {
    [[NSMutableURLRequest alloc] init];
})

CS_LINKCODE_METHOD_IMP(CSNetworkTool, NSString, url, {
    self->_url = value;
})

CS_LINKCODE_METHOD_IMP(CSNetworkTool, NSDictionary, arguments, {
    self->_argument = value;
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpMethod, method, {
    self->_httpMethod = value;
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, success, {
    self.successBlock = [value copy];
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, fail, {
    self.failBlock = [value copy];
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, progress, {
    self.progressBlock = [value copy];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,begin,{
    [self beginRequest];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cancel,{
    [self cancelRequest];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cs_post,{
    self.httpMethod = CSHttpMethodPost;
    self.currentTask = [self cs_request_post];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cs_get,{
    self.httpMethod = CSHttpMethodGet;
    self.currentTask = [self cs_request_get];
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, NSTimeInterval, timeout, {
    self.requestTimeout = value;
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSResponseFormat, setResponseFormat, {
    self.responseFormat = value;
})
@end
