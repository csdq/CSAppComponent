//
//  CSNetworkTool+SOAP.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/4/20.
//

#import "CSNetworkTool+SOAP.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation CSNetworkTool (SOAP)
CS_LINKCODE_METHOD_IMP(CSNetworkTool, NSString, soapArguments, {
    wSelf->_soapArguments = value;
})

- (RACSubject *(^)(void))rac_soapRequest{
    return ^{
        RACSubject *subject = self.resultSubject;
        NSString *soapMessage = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:tem=\"http://tempuri.org/\"><soap12:Body>\
                                 %@</soap12:Body></soap12:Envelope>",
                                 self->_soapArguments
                                 ];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self->_url]];
        
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
        [request setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //    [request addValue:@"http://tempuri.org/Process" forHTTPHeaderField:@"SOAPAction"];
        [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
        
        [request setHTTPMethod:@"POST"];
        NSLog(@"\nWeb service Request:\n%@\n%@",request.URL,soapMessage);
        [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        CSHTTPCommonResponseModel *model = [CSHTTPCommonResponseModel new];
                                                        model.responseObject = data;
                                                        model.response = (NSHTTPURLResponse *)response;
                                                        model.iSuccess = ((NSHTTPURLResponse *)response).statusCode == 200;
                                                        model.error = error;
                                                        [subject sendNext:model];
                                                    });
                                                }];
        [task resume];
        return subject;
    };
}

@end
