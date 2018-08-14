//
//  CSNetworkTool+RAC_Request.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/20.
//

#import "CSNetworkTool+RAC_Request.h"
#import "CSDataTool.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CSNetworkTool (RAC_Request)
- (RACSubject *(^)(void))rac_request{
    return ^{
        NSLog(@"URL: %@\nArguments:%@",self->_url,self->_argument);
        RACSubject *subject = self.resultSubject;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = self.requestTimeout;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text-plain/json"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/xml"];
        switch (self.httpMethod) {
            case CSHttpMethodGet:
            {
                self.currentTask = [manager GET:self->_url parameters:self->_argument progress:^(NSProgress * _Nonnull uploadProgress) {
                    //                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    //                    model.progress = uploadProgress;
                    //                    model.iSuccess = YES;
                    //                    [subject sendNext:model];
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSLog(@"Response:\n%@",responseObject);
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.iSuccess = YES;
                    model.responseObject = responseObject;
                    [subject sendNext:model];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [subject sendError:error];
                }];
            }
                break;
            case CSHttpMethodPost:
            default:
            {
                self.currentTask = [manager POST:self->_url parameters:self->_argument progress:^(NSProgress * _Nonnull uploadProgress) {
                    //                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    //                    model.progress = uploadProgress;
                    //                    model.iSuccess = YES;
                    //                    [subject sendNext:model];
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                    model.task = task;
                    model.responseObject = responseObject;
                    model.iSuccess = YES;
                    [subject sendNext:model];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [subject sendError:error];
                }];
            }
                break;
        }
        [subject setNameWithFormat:@"%@ rac_request: url:%@ arg:%@",subject.name,self->_url,self->_argument];
        return subject;
    };
}

- (RACSubject *(^)(void))rac_soap_request{
    return ^{
        RACSubject *subject = self.resultSubject;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = self.requestTimeout;
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/xml"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
        switch (self.httpMethod) {
            case CSHttpMethodPost:
            default:
            {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self->_url]];
                NSString *soapXML = self->_argument[K_NETWORKTOOL_ARGUMENT_KEY_SOAP_XML];
                NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapXML length]];
                [request addValue:@"http://tempuri.org/Process" forHTTPHeaderField:@"SOAPAction"];
                [request setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPMethod:@"POST"];
                [request setHTTPBody:[soapXML dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
                self.currentTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    if(error) {
                                                        if(error.code == NSURLErrorCancelled) {
                                                            return;
                                                        }
//                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSError *err = [NSError errorWithDomain:@"com.csdq.xml" code:error.code userInfo:@{@"info":(error.localizedFailureReason==nil?@"发生错误":error.localizedFailureReason)}];
                                                            [subject sendError:err];
//                                                        });
                                                    } else {
                                                        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                        NSString *resultXMLStr = [CSDataTool htmlDecode:str];
                                                        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"(<\\?xml)[a-zA-Z0-9\\s=\"\\.-]+(\\?>)" options:NSRegularExpressionCaseInsensitive error:nil];
                                                        resultXMLStr = [regular stringByReplacingMatchesInString:resultXMLStr options:NSMatchingReportCompletion range:NSMakeRange(0, resultXMLStr.length) withTemplate:@"$4"];
                                                        NSXMLParser *pareser = [[NSXMLParser alloc] initWithData:[resultXMLStr dataUsingEncoding:NSUTF8StringEncoding]];
                                                        [subject sendNext:pareser];
                                                    }
                                                }];
                [self.currentTask resume];
            }
                break;
        }
        [subject setNameWithFormat:@"%@ rac_request: url:%@ arg:%@",subject.name,self->_url,self->_argument];
        return subject;
    };
}

@end
