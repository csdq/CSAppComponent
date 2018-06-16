//
//  CSNetworkTool.m
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import "CSNetworkTool.h"
#import "AFNetworking.h"
#import "CSHTTPResponseModel.h"
#import "CSHTTPCommonResponseModel.h"
#import "CSErrorDomain.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
NSString *K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML = @"K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML";
@implementation CSRequestPage
+ (instancetype)page{
    return [self pageWith:1 size:20];
}

+ (instancetype)pageWith:(NSInteger)index size:(NSInteger)size{
    CSRequestPage *page = [CSRequestPage new];
    page.pageIndex = @(index);
    page.pageSize = @(size);
    return page;
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

CS_PROPERTY_INIT(NSMutableURLRequest, request, {
    [[NSMutableURLRequest alloc] init];
})

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
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    switch (self.httpMethod) {
        case CSHttpMethodPost:
        {
            _currentTask = [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
                if(self.progressBlock){
                    self.progressBlock(uploadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if(self.successBlock){
                    self.successBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if(self.failBlock){
                    self.failBlock(error);
                }
            }];
        }
            break;
        case CSHttpMethodGet:
        default:
            _currentTask = [manager GET:_url parameters:_argument progress:^(NSProgress * _Nonnull downloadProgress) {
                if(self.progressBlock){
                    self.progressBlock(downloadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if(self.successBlock){
                    self.successBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if(self.failBlock){
                    self.failBlock(error);
                }
            }];
            break;
    }
}
// CSRequest
//MARK: 请求方法执行
- (NSURLSessionDataTask *)cs_request_post{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    manager.securityPolicy.allowInvalidCertificates = YES;
    NSLog(@"CSHTTP REQUEST\n%@%@",_url,_argument);
    return [manager POST:_url parameters:_argument progress:^(NSProgress * _Nonnull uploadProgress) {
        if(self.progressBlock){
            self.progressBlock(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",responseObject);
        if(self.successBlock){
            CSHTTPResponseModel *model = [CSHTTPResponseModel modelFromDict:responseObject];
            if([CSErrorDomain isSuccess:model.status]){
                self.successBlock(model);
            }else{
                if(self.failBlock){
                    self.failBlock(model);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CSHTTP ERROR\n%@",error);
        if(self.failBlock){
            CSHTTPResponseModel *model = [CSHTTPResponseModel new];
            model.message = [error localizedFailureReason];
            model.status = @(error.code);
            self.failBlock(model);
        }
    }];
}

- (NSURLSessionDataTask *)cs_request_get{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    return [manager GET:_url parameters:_argument progress:^(NSProgress * _Nonnull downloadProgress) {
        if(self.progressBlock){
            self.progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"CSHTTP RESPONSE\n%@",responseObject);
        if(self.successBlock){
            CSHTTPResponseModel *model = [CSHTTPResponseModel modelFromDict:responseObject];
            if([CSErrorDomain isSuccess:model.status]){
                self.successBlock(model);
            }else{
                if(self.failBlock){
                    self.failBlock(model);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CSHTTP ERROR\n%@",error);
        if(self.failBlock){
            CSHTTPResponseModel *model = [CSHTTPResponseModel new];
            model.message = [error localizedFailureReason];
            model.status = @(error.code);
            self.failBlock(model);
        }
    }];
}

- (void)cancelRequest{
    [_currentTask cancel];
}

CS_LINKCODE_METHOD_IMP(CSNetworkTool, NSString, url, {
    wSelf->_url = value;
})

CS_LINKCODE_METHOD_IMP(CSNetworkTool, NSDictionary, arguments, {
    wSelf->_argument = value;
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpMethod, method, {
    wSelf->_httpMethod = value;
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, success, {
    wSelf.successBlock = [value copy];
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, fail, {
    wSelf.failBlock = [value copy];
})

CS_LINKCODE_METHOD_IMP_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, progress, {
    wSelf.progressBlock = [value copy];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,begin,{
    [wSelf beginRequest];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cancel,{
    [wSelf cancelRequest];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cs_post,{
    wSelf.httpMethod = CSHttpMethodPost;
    wSelf->_currentTask = [wSelf cs_request_post];
})

CS_LINKCODE_METHOD_VOID_IMP(CSNetworkTool,cs_get,{
    wSelf.httpMethod = CSHttpMethodGet;
    wSelf->_currentTask = [wSelf cs_request_get];
})

@end
