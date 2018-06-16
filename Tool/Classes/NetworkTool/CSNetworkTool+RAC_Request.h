//
//  CSNetworkTool+RAC_Request.h
//  CSAppComponent
//
//  Created by Mr.s on 2017/4/20.
//

#import "CSNetworkTool.h"
@class CSXMLParserDelegate;
@interface CSNetworkTool (RAC_Request)
/******************RAC处理方式的请求*********************/
///设置好url argument等参数后 进行处理 返回RACSubject
CS_LINKCODE_METHOD_VOID(RACSubject, rac_request)
//返回解析后的对象
CS_LINKCODE_METHOD_VOID(RACSubject, rac_soap_request)
@end
