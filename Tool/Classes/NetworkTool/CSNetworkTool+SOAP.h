//
//  CSNetworkTool+SOAP.h
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/20.
//
#import "CSNetworkTool.h"

@interface CSNetworkTool (SOAP)
///soap请求参数
CS_LINKCODE_METHOD(CSNetworkTool, NSString, soapArguments)
///xml soap request 针对HIS等接口 需要设置好soap arg参数
CS_LINKCODE_METHOD_VOID(RACSubject, rac_soapRequest)
//- (RACSubject *)rac_soapRequest;
@end
