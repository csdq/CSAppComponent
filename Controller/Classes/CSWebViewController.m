//
//  CSWebViewController.m
//   CSAppComponent
//
//  Created by Mr.s on 2017/3/27.
//

#import "CSWebViewController.h"
#import <Webkit/WebKit.h>
#import <Masonry/Masonry.h>
@interface CSWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    NSURLRequest *_request;
    NSURL *_baseURL;
}
@property (nonatomic,strong) WKWebView * webView;
@end

@implementation CSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)cs_setView{
    [super cs_setView];
    CS_ADD_MAIN_VIEW_AND_FULLFILL(self.webView)
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
    }
    return _webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: delegate - navigation
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    [self showLoadState];
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
    [self hideLoadState];
    NSLog(@"didFinishNavigation");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;{
    NSLog(@"didFailNavigation");
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    NSLog(@"didReceiveAuthenticationChallenge");
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    NSLog(@"webViewWebContentProcessDidTerminate");
}

//MARK: delegate - UI
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration");
    return webView;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    NSLog(@"webViewDidClose");
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
    NSLog(@"runJavaScriptAlertPanelWithMessage");
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
    [self.webSubject sendNext:message];
}
//MARK:
CS_LINKCODE_METHOD_IMP(CSWebViewController, NSURL, loadURL, {
    if([value.absoluteString hasPrefix:@"http"] || [value.absoluteString hasPrefix:@"file"] || [value.absoluteString hasPrefix:@"ftp"]){
        wSelf->_request = [NSURLRequest requestWithURL:value];
    }else{
        wSelf->_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[wSelf->_baseURL.absoluteString stringByAppendingString:value.absoluteString]]];
    }
    NSLog(@"%@",wSelf->_request.URL);
    [wSelf.webView loadRequest:wSelf->_request];
})

CS_LINKCODE_METHOD_IMP(CSWebViewController, NSString, loadHTML, {
    [wSelf.webView loadHTMLString:value baseURL:wSelf->_baseURL];
})

CS_LINKCODE_METHOD_IMP(CSWebViewController, NSURL, baseURL, {
    wSelf->_baseURL = value;
})

CS_PROPERTY_INIT_CODE(RACSubject, webSubject, {
    [RACSubject subject];
})

@end
