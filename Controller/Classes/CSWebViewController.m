//
//  CSWebViewController.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/27.
//

#import "CSWebViewController.h"
#import "CSBaseNavViewController.h"
#import <Webkit/WebKit.h>
#import <Masonry/Masonry.h>
@interface CSWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    NSURLRequest *_request;
    NSURL *_baseURL;
    dispatch_semaphore_t _semaphore;
    NSLock *_webJSCmdlock;
}
@property (nonatomic,strong) RACCommand * webJSCmd;
@end

@implementation CSWebViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _webJSCmdlock = [[NSLock alloc] init];
    _webLoadFinishedSubject = [RACSubject subject];
    _semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [self setView];
}

- (void)dealloc{
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [_webView removeFromSuperview];
    _webView = nil;
    _request = nil;
    _baseURL = nil;
    _webActionSubject = nil;
    _webJSCmd = nil;
    _webJSCmdlock = nil;
    _webLoadFinishedSubject = nil;
}

- (void)runJavascript:(NSString *)js identifier:(NSString *)identifier{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        [self->_webJSCmdlock lock];
        [self.webJSCmd execute:@{@"js":js,@"id":identifier}];
    });
}

- (NSString *)jsStringWithoutWhite:(NSString *)js{
    NSString *_js = [js stringByReplacingOccurrencesOfString:@" " withString:@""];
    [_js stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [_js stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_js stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return _js;
}

- (void)setView{
    WKWebView *mainView = self.webView;
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainView];
    if (@available(iOS 11,*)){
        [NSLayoutConstraint activateConstraints:
         @[
           [mainView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
           [mainView.rightAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.rightAnchor],
           [mainView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
           [mainView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor],
           ]];
    }else{
        id<UILayoutSupport> top = self.topLayoutGuide;
        id<UILayoutSupport> bottom = self.bottomLayoutGuide;
        if(self.cs_navigationBar.superview||([self.navigationController isKindOfClass:[CSNavViewController class]]&&((CSBaseNavViewController *)self.navigationController).useCustomNavigationBar)){
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-44-[mainView]-0-[bottom]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView,top,bottom)]];
        }else{
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mainView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-0-[mainView]-0-[bottom]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView,top,bottom)]];
        }
    }
}

- (WKWebView *)webView{
    if(!_webView){
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        [configuration.userContentController addScriptMessageHandler:self name:@"iOSApp"];
        if (@available(iOS 9.0, *)) {
            configuration.applicationNameForUserAgent = @"CSApp UserAgent";
        } else {
            // Fallback on earlier versions
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        @weakify(self)
        _webJSCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self)
                @weakify(self)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_semaphore_wait(self->_semaphore, DISPATCH_TIME_FOREVER);
                    if([input isKindOfClass:[NSDictionary class]] && [input[@"js"] isKindOfClass:[NSString class]]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.webView evaluateJavaScript:input[@"js"] completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                                @strongify(self)
                                if(error && error.code!=0){
                                    [self.webJSResultSubject sendError:error];
                                }else{
                                    [self.webJSResultSubject sendNext:input[@"id"]];
                                }
                            }];
                        });
                    }else{
                        NSLog(@"input should javascript string");
                    }
                    [self->_webJSCmdlock unlock];
                    [subscriber sendCompleted];
                    dispatch_semaphore_signal(self->_semaphore);
                });
                return nil;
            }];
        }];
    }
    return _webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: delegate - navigation
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"decidePolicyForNavigationAction");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"decidePolicyForNavigationResponse");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    dispatch_semaphore_signal(_semaphore);
    [self.webLoadFinishedSubject sendNext:navigation];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;{
    NSLog(@"didFailNavigation");
    [self.webLoadFinishedSubject sendError:error];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    completionHandler(NSURLSessionAuthChallengeUseCredential,[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    NSLog(@"didReceiveAuthenticationChallenge");
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    NSLog(@"webViewWebContentProcessDidTerminate");
}

//MARK: delegate - UI
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration");
    if (!navigationAction.targetFrame.isMainFrame) {
        [self.webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    NSLog(@"webViewDidClose");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
    NSLog(@"runJavaScriptAlertPanelWithMessage %@",message);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
    NSLog(@"runJavaScriptConfirmPanelWithMessage result");
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    completionHandler(prompt);
    NSLog(@"runJavaScriptTextInputPanelWithPrompt defaultText");
}


- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)){
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)){
    return self;
}
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)){
    
}
//MARK: script message handler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.webActionSubject sendNext:message];
}
//MARK:
CS_LINKCODE_METHOD_IMP(CSWebViewController, NSURL, loadURL, {
    if([value.absoluteString hasPrefix:@"http:"] || [value.absoluteString hasPrefix:@"https"] || [value.absoluteString hasPrefix:@"file:"] || [value.absoluteString hasPrefix:@"ftp:"]){
        self->_request = [NSURLRequest requestWithURL:value];
    }else{
        self->_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self->_baseURL.absoluteString stringByAppendingString:value.absoluteString]]];
    }
    NSLog(@"%@",self->_request.URL);
    [self.webView loadRequest:self->_request];
})

CS_LINKCODE_METHOD_IMP(CSWebViewController, NSString, loadHTML, {
    [self.webView loadHTMLString:value baseURL:self->_baseURL];
})

CS_LINKCODE_METHOD_IMP(CSWebViewController, NSURL, baseURL, {
    self->_baseURL = value;
})

CS_PROPERTY_INIT_CODE(RACSubject, webActionSubject, {
    [RACSubject subject];
})

CS_PROPERTY_INIT_CODE(RACSubject, webJSResultSubject, {
    [RACSubject subject];
})
@end
