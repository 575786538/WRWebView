//
//  WRWebView.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import "WRWebView.h"
#import <AVFoundation/AVFoundation.h>
#import "WRWebNavigationView.h"
#import "NSURL+WRTool.h"
#import "WKWebView+WRWebCookie.h"
#import "WKWebView+Interactive.h"
#import "WKWebView+LongPress.h"

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height


static BOOL isloadSuccess = NO;
static ModelBlock Callback = nil;

@interface WRWebView ()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, retain) NSArray<NSString *> *buttonTitle;
@property (nonatomic,   copy) NSString *currentURLString;  //当前页面的URL
@property (nonatomic, retain) WKWebViewConfiguration *WKConfiguration;
@property (nonatomic, retain) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) UIProgressView *progressView;   //进度条
@property (nonatomic, retain) NSMutableArray *messageModelArray;

@property (nonatomic, retain) WRWebNavigationView *nav;
@property (nonatomic, copy) void(^QRCodeBlock) (NSString *url);
@property (nonatomic, assign) BOOL longpress;

@end

@implementation WRWebView
+(instancetype)shareInstance{
    static WRWebView *webView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webView = [[self alloc]init];
        webView.longpress = NO;
        
    });
    return webView;
}


#pragma mark --- 网络请求
/**
 *  重新加载网页
 */
- (void)reload{
    [self.webView reload];
}

/**
 *  重新加载网页,忽略缓存
 */
- (void)reloadFromOrigin{
    [self.webView reloadFromOrigin];
}
/**
 *  请求网络资源 post
 *  @param request  请求的具体地址和设置
 *  @param params   参数
 */
- (void)loadRequestURL:(NSMutableURLRequest *)request params:(NSDictionary*)params{
    NSURL *URLString = [NSURL generateURL:request.URL.absoluteString params:params];
    request.URL = URLString;
    [self loadRequestURL:request];
}

// 请求网络资源
- (void)loadRequestURL:(NSMutableURLRequest *)request{
    _webView = _webView ? _webView : self.webView;
    NSString *url = request.URL.host;
        
    // 插入cookies
    if (url)[self.WKConfiguration.userContentController addUserScript:[_webView searchCookieForUserScriptWithDomain:url]];
    if (url)[request setValue:[_webView phpCookieStringWithDomain:url] forHTTPHeaderField:@"Cookie"];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];//重置空白界面
    [_webView loadRequest:request];
}

//加载本地HTML页面
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *URL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [self.webView loadHTMLString:htmlCont baseURL:URL];
}
#pragma mark --- JS 与 OC 交互
//OC调用JS
- (void)OCCallJS:(NSString *)method handler:(void (^)(id response, NSError *error))handler{
    NSLog(@"Call:%@",method);
    [_webView evaluateJavaScript:method completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"result:%@ error:%@",result,error);
    }];
}
- (void)addScriptMessageHandler:(NSString *)message observeValue:(nullable void (^)(WebModel *model))handler{
    @try {
        [self.WKConfiguration.userContentController addScriptMessageHandler:self name:message];
    } @catch (NSException *exception) {
        NSLog(@"异常信息：%@",exception);
    } @finally {
        
    }
    WebModel *model = [WebModel new];
    model.message_name = message;
    model.MessageHandler = handler;
    [self.messageModelArray addObject:model];    
}
// messageHandler 代理  JS调用OC   
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    //__weak typeof(self)weakSelf = self;

    [_webView HandleMessage:message WithuserContentController:userContentController WithModelArray:self.messageModelArray AndWebModel:^(WebModel * _Nullable model) {
        NSLog(@"model.message:%@",model.message);
        
        Callback?Callback(model):nil;
    }];
}
#pragma mark --- Cookies
//读取Cookies
-(NSMutableArray *)ReadLocalDiskCookies{
    return [self.webView obtainHTTPCookieStorage];
}
//插入Cookies
- (void)setCookie:(NSHTTPCookie *)cookie{
    [self.webView insertCookie:cookie];
}
//删除某个Cookies
- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))handler{
    [self.webView deleteWKCookie:cookie completionHandler:handler];
}
//删除域名下的Cookies
- (void)deleteWKCookiesByHost:(NSURL *_Nullable)host completionHandler:(nullable void (^)(void))handler{
    [self.webView deleteWKCookiesByHost:host completionHandler:handler];
}
//清除HTML文件
-(void)clearHTMLCache{
    [self.webView clearHTMLCache];
}
//清除所有cookies
-(void)clearAllCookies{
    [self.webView clearAllCookies];
}
//清除所有缓存（不包含Cookies）
- (void)clearWebCacheFinish:(void(^_Nullable)(BOOL finish,NSError * _Nullable error))handler{
    NSSet *websiteDataTypes = [NSSet setWithArray:
                               @[WKWebsiteDataTypeDiskCache,
                                 WKWebsiteDataTypeOfflineWebApplicationCache,
                                 WKWebsiteDataTypeMemoryCache,
                                 WKWebsiteDataTypeLocalStorage,
                                 //WKWebsiteDataTypeCookies,
                                 WKWebsiteDataTypeSessionStorage,
                                 WKWebsiteDataTypeIndexedDBDatabases,
                                 WKWebsiteDataTypeWebSQLDatabases
                                 ]];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        handler ? handler(YES,nil):nil;
    }];
}

// 接收通知进行网页跳转
-(void)loadRequestFromNotification:(NSNotification *)noti{
    NSString * urlStr = [NSString string];
    for (NSString * key in [noti userInfo]){
        if ([key isEqualToString:@"LoadQRCodeUrl"]) {
            urlStr = [noti userInfo][key];
        }
    }
    NSLog(@"urlStr = %@ ",urlStr);
    
    _QRCodeBlock?_QRCodeBlock(urlStr):nil;
    
    NSURL * url = [NSURL URLWithString:urlStr];
    if ([urlStr containsString:@"http"] || [[UIApplication sharedApplication]canOpenURL:url]) {
     [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}
- (void)notificationInfoFromQRCode:(nullable void (^)(NSString *info))block{
    _QRCodeBlock = block;
}
#pragma mark --- 界面加载
-(instancetype)init{
    if (self == [super init]) {
        //[self.view addSubview:self.webView];
        self.nav = [WRWebNavigationView shareInstance];
        self.nav.defaultType = YES;
        self.showLog = NO;
        self.isShowProgress = YES;
        [self loadRequestURL:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self)weekSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weekSelf.view addSubview:self.webView];
        [weekSelf interface];
    });
   
}
-(void)interface{
    UIImage *menuImage = [UIImage imageNamed:@"navigationbar_more"];
    menuImage = [menuImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *menuBtn = [[UIButton alloc] init];
    [menuBtn setImage:menuImage forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuBtn sizeToFit];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuItem;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addBackButton];
}

- (void)WRRemoveScriptMessageHandler{
    
    if (self.messageModelArray.count>0) {
        for (WebModel *model in self.messageModelArray) {
            if (model.message_name) {
                [_WKConfiguration.userContentController removeScriptMessageHandlerForName:model.message_name];
            }
        }
    }
    [self.messageModelArray removeAllObjects];
}
#pragma mark -- NavigationDelegate
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
    isloadSuccess = YES;
    //获取当前 URLString
    __weak typeof(self)weekSelf = self;
    [webView evaluateJavaScript:@"window.location.href" completionHandler:^(id _Nullable urlStr, NSError * _Nullable error) {
        if (error == nil) {
            weekSelf.currentURLString = urlStr;
        }
    }];
    
    NSString *heightString = @"document.body.scrollHeight";
    [webView evaluateJavaScript:heightString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"html 的高度：%@", result);
    }];
}
//web跳转交互
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *urlStr = navigationAction.request.URL.scheme.lowercaseString;
    if (_longpress) {
        _longpress = NO;
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if ([urlStr containsString:@"weixin://wap/pay"] || [urlStr containsString:@"alipay://alipayclient"]) {
        //跳转支付宝与微信
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else if (![urlStr containsString:@"http"] && ![urlStr containsString:@"about"] && ![urlStr containsString:@"file"]) {
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"]||[navigationAction.request.URL.host.lowercaseString isEqualToString:@"apps.apple.com"])
        {
            [UIAlertController WRlertWithTitle:@"提示" message:@"是否打开App Store？" action1Title:@"返回" action2Title:@"去下载" action1:^{
                [webView goBack];
            } action2:^{
                [NSURL safariOpenURL:navigationAction.request.URL];
            }];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        [NSURL openURL:navigationAction.request.URL];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else{
        //  在发送请求之前，决定是否跳转
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

#pragma mark -- Nav

-(void)setProgressTintColor:(UIColor *)progressTintColor{
    _progressTintColor = progressTintColor;
    self.progressView.progressTintColor = progressTintColor;
}
- (void)setProgressTrackTintColor:(UIColor *)progressTrackTintColor{
    _progressTrackTintColor = progressTrackTintColor;
    self.progressView.trackTintColor = progressTrackTintColor;
}
-(void)setIsShowProgress:(BOOL)isShowProgress{
    if (isShowProgress == NO) {
        [self.progressView removeFromSuperview];
    }
}

//监控title和进度
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == _webView) {
            [self.progressView setAlpha:1.0f];
            float progressValue = fabsf([change[@"new"] floatValue]);
            if (progressValue > _progressView.progress) {
                
                [_progressView setProgress:progressValue animated:YES];
            }else{
                
                [_progressView setProgress:progressValue animated:NO];
            }
            
            if(progressValue >= 1.0f)
            {
                __weak typeof(self)weekSelf = self;
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [weekSelf.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [weekSelf.progressView setProgress:0.0f animated:NO];
                }];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]){
        if (object == _webView){
            if (self.webTitle == nil) {
                self.title = _webView.title;
            }else{
                self.title = self.webTitle;
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        NSLog(@"%@",keyPath);
    }
}

/** 添加返回按钮 */
- (void)addBackButton{
    self.navigationItem.leftBarButtonItem = self.backItem;
    [(UIButton *)self.backItem.customView addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
}
- (void)goback{
    [self backNative];
}

/** 点击返回按钮的返回方法 */
- (void)backNative {
    //判断是否有上一层H5页面
    if ([self.webView canGoBack])
    {
        //如果有则返回
        [self.webView goBack];
        
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
        self.navigationItem.leftBarButtonItems = @[self.backItem];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)goForward{
    
    [self.webView canGoForward] ? [_webView goForward] : NULL;
}
- (void)dealloc{
    [_webView clearHTMLCache];
    if(self.webView.scrollView.delegate) self.webView.scrollView.delegate = nil;
    if(self.webView.navigationDelegate) self.webView.navigationDelegate = nil;
    if(self.webView.UIDelegate) self.webView.UIDelegate = nil;
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    if(self.progressView)[_progressView removeFromSuperview];
     self.progressView = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self WRRemoveScriptMessageHandler];
    
}


- (void)menuBtnAction:(UIButton *)sender{
    __weak typeof(self)weekSelf = self;
    NSMutableArray *buttonTitleArray = [NSMutableArray array];
    [buttonTitleArray addObjectsFromArray:@[@"safari打开", @"复制链接", @"刷新"]];
    [self.nav defaultMenuShowInViewController:self title:@"更多" message:nil buttonTitleArray:buttonTitleArray buttonTitleColorArray:nil popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
        
    } block:^(UIAlertController * _Nonnull alertController, UIAlertAction * _Nonnull action, NSInteger buttonIndex)
     {
         if (buttonIndex == 0){
             if (weekSelf.currentURLString.length > 0){
                 /*! safari打开 */
                 [NSURL safariOpenURL:[NSURL URLWithString:weekSelf.currentURLString]];
                 return;
             }
             else{
                 [UIAlertController WRlertWithTitle:@"提示" message:@"无法获取当前链接" completion:nil];
             }
         }else if (buttonIndex == 1){
             /*! 复制链接 */
             if (weekSelf.currentURLString.length > 0){
                 [UIPasteboard generalPasteboard].string = weekSelf.currentURLString;
                 return;
             }else{
                 [UIAlertController WRlertWithTitle:@"提示" message:@"无法获取当前链接" completion:nil];
             }
         }else if (buttonIndex == 2){
             [weekSelf.webView reloadFromOrigin];
             
         }
         
     }];
}
#pragma mark --- 初始化
-(WKWebView *)webView{
    if (!_webView) {
        if (self.navigationController.navigationBar.hidden) {
             _webView = [[WKWebView alloc] initWithFrame:CGRectMake( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT  - 44) configuration:self.WKConfiguration];
        }else{
            _webView = [[WKWebView alloc] initWithFrame:CGRectMake( 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT  - 44 - 20) configuration:self.WKConfiguration];
        }
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
        _webView.scrollView.delegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.bounces = YES;
        _webView.multipleTouchEnabled = YES;
        _webView.userInteractionEnabled = YES;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _webView.scrollView.showsVerticalScrollIndicator = YES;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        WKHTTPCookieStore *cookieStore = _webView.configuration.websiteDataStore.httpCookieStore;
        [_webView syncCookiesToWKHTTPCookieStore:cookieStore];//同步cookie
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        //添加长按手势
        __weak typeof(self)weakSelf = self;
        [_webView  addGestureRecognizerObserverWebElements:^(BOOL longpress) {
            weakSelf.longpress = longpress;
        }];
        
    }
    return _webView;
}
-(WKWebViewConfiguration *)WKConfiguration{
    if (!_WKConfiguration) {
        _WKConfiguration = [[WKWebViewConfiguration alloc] init];
        _WKConfiguration.userContentController = [[WKUserContentController alloc] init];
        _WKConfiguration.preferences = [[WKPreferences alloc] init];
        _WKConfiguration.preferences.minimumFontSize = 8;
        _WKConfiguration.preferences.javaScriptEnabled = YES;
        _WKConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        _WKConfiguration.processPool = [[WKProcessPool alloc] init];
        _WKConfiguration.allowsInlineMediaPlayback = YES;
        _WKConfiguration.processPool = [[WKProcessPool alloc] init];
        _WKConfiguration.allowsInlineMediaPlayback = YES;
        _WKConfiguration.allowsAirPlayForMediaPlayback = YES;
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [_WKConfiguration.userContentController addUserScript:noneSelectScript];

    }
    return _WKConfiguration;
}

-(UIProgressView *)progressView{
    if (!_progressView) {
            _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 2)];
            _progressView.tintColor = [UIColor colorWithRed:50.0/255 green:135.0/255 blue:255.0/255 alpha:1.0];
            _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _progressView.hidden = NO;
            [_progressView setAlpha:0.0f];
            [self.webView addSubview:_progressView];
        
    }
    return _progressView;
}
-(WebModel *)model{
    if (!_model) {
        _model = [[WebModel alloc]init];
    }
    return _model;
}
-(NSMutableArray *)messageModelArray{
    if (!_messageModelArray) {
        self.messageModelArray = [NSMutableArray array];
    }
    return _messageModelArray;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

*/

@end
