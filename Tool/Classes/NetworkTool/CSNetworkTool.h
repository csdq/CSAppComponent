//
//  CSNetworkTool.h
//   CSAppComponent
//
//  Created by temps on 2017/3/14.
//  Copyright © Mr.s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSHTTPCommonResponseModel.h"
#import "CSHelper.h"

@class RACSubject;
@class CSHTTPResponseModel;

extern NSString *K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML;

typedef enum : NSUInteger {
    CSHttpMethodGet,
    CSHttpMethodPost,
    CSHttpMethodDelete,
    CSHttpMethodPut
} CSHttpMethod;

typedef enum CSDataState{
    CSDataStateError,
    CSDataStateNormal,
    CSDataStateNomore
}CSDataState;

@interface CSRequestPage : NSObject
CS_PROPERTY_DECLARE(NSNumber, pageIndex);
CS_PROPERTY_DECLARE(NSNumber, pageSize);
CS_PROPERTY_DECLARE(NSNumber, totalRecordCount);
CS_PROPERTY_DECLARE(NSNumber, totalPageCount)
CS_PROPERTY_DECLARE(NSNumber, nomoreData)
///状态
@property (nonatomic , assign) CSDataState state;
+ (instancetype)page;
+ (instancetype)pageWith:(NSInteger)index size:(NSInteger)size;
///索引加1: pageIndex+1 @return 返回request page对象
- (instancetype)add;
///索引减1: pageIndex-1 @return 返回request page对象
- (instancetype)subtract;
@end

typedef void(^CSHttpRequestCommonBlock)(id obj);
@interface CSNetworkTool : NSObject
{
    NSURLSessionDataTask *_currentTask;
    //    请求URL
    NSString *_url;
    //    参数 字典形式
    NSDictionary *_argument;
    /////SOAP XML string
    NSString *_soapArguments;
   
}
CS_PROPERTY_ASSIGN_DECLARE(CSHttpMethod ,httpMethod)
CS_PROPERTY_DECLARE(NSMutableURLRequest, request)
///请求结果RACSubject
CS_PROPERTY_DECLARE(RACSubject ,resultSubject);
//创建实例
+ (instancetype)createInstance;
///必要-设置url
CS_LINKCODE_METHOD(CSNetworkTool, NSString, url)
///可选-参数
CS_LINKCODE_METHOD(CSNetworkTool, NSDictionary, arguments)
///block模式 成功回调
CS_LINKCODE_METHOD_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, success)
///block模式 失败回调
CS_LINKCODE_METHOD_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, fail)
///block模式 上传/下载文件的进度
CS_LINKCODE_METHOD_ASSIGN(CSNetworkTool, CSHttpRequestCommonBlock, progress)
/*******************请求结果是用Model封装****************************/
CS_LINKCODE_METHOD_VOID(CSNetworkTool, cs_post)
CS_LINKCODE_METHOD_VOID(CSNetworkTool, cs_get)
/**********************普通请求结果 原始值返回 不做解析和封装**************************/
//设置请求方法
CS_LINKCODE_METHOD_ASSIGN(CSNetworkTool, CSHttpMethod, method)
//开始请求 需要事先指定http方法 默认get
CS_LINKCODE_METHOD_VOID(CSNetworkTool, begin)
/**********************取消请求***************************/
CS_LINKCODE_METHOD_VOID(CSNetworkTool, cancel)
@end
