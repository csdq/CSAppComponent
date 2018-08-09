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
        _pageIndex = @([_pageIndex integerValue] + 1);
    }
    return self;
}

- (instancetype)subtract{
    @synchronized(self){
        _pageIndex = @(MAX(0,[_pageIndex integerValue] - 1));
    }
    return self;
}

- (NSNumber *)nomoreData{
    return @([self.totalPageCount isEqualToNumber:self.pageIndex]);
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
    return [CSNetworkTool new];
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
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer.HTTPRequestHeaders setValue:@"no-store" forKey:@"Cache-Control"];
    NSLog(@"CSHTTP REQUEST\n%@%@",_url,_argument);
    switch (self.httpMethod) {
        case CSHttpMethodPost:
        {
            self.currentTask = [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
                if(self.progressBlock){
                    self.progressBlock(uploadProgress);
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
//    [manager.requestSerializer.HTTPRequestHeaders setValue:@"no-store" forKey:@"Cache-Control"];
//    manager.securityPolicy.allowInvalidCertificates = YES;
    NSLog(@"CSHTTP REQUEST\n%@%@",_url,_argument);
    return [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
        if(self.progressBlock){
            self.progressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",responseObject);
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
            model.iSuccess = YES;
            model.responseObject = error;
            self.failBlock(model);
        }
    }];
}

- (NSURLSessionDataTask *)cs_request_get{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = self.requestTimeout;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    return [manager GET:_url parameters:_argument progress:^(NSProgress * _Nonnull downloadProgress) {
        if(self.progressBlock){
            self.progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",responseObject);
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
            model.iSuccess = YES;
            model.responseObject = error;
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
@end
