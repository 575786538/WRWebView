//
//  WRWebView.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import "WKBaseWebView.h"
#import <WebKit/WebKit.h>
#import "WebModel.h"
NS_ASSUME_NONNULL_BEGIN


typedef void (^ModelBlock)(WebModel *model);
@interface WRWebView : WKBaseWebView

@property (nonatomic, retain) WKWebView *webView;

@property (nonatomic,   copy) NSString *URLString;

//@property (nonatomic,   weak) id<PAWKScriptMessageHandler> messageHandlerDelegate;
@property (nonatomic, assign) BOOL isShowProgress;//是否显示进度条 默认显示

@property (nonatomic, retain) UIColor *progressTintColor;  //进度条颜色

@property (nonatomic, retain) UIColor *progressTrackTintColor;

@property (nonatomic, assign) BOOL openCache;   //缓存

@property (nonatomic, assign) BOOL showLog;     //执行日志

@property (nonatomic, strong) WebModel *model;

@property (nonatomic, copy) NSString *webTitle;

+ (instancetype)shareInstance;

#pragma mark --- 网络请求
// 加载网页 加载网页时注入 cookies 把链接更改为 NSMutableURLRequest ，自定义缓存的方式和其他的一些具体的设置
- (void)loadRequestURL:(NSMutableURLRequest *)request;

- (void)loadRequestURL:(NSMutableURLRequest *)request params:(NSDictionary*)params;
//加载本地网页
- (void)loadLocalHTMLWithFileName:(NSString *)htmlName;
/** 重新加载webview */
- (void)reload;
/** 重新加载网页,忽略缓存 */
- (void)reloadFromOrigin;


#pragma mark --- JS 与 OC 交互
//OC调用JS
- (void)OCCallJS:(NSString *)method handler:(void (^)(id response, NSError *error))handler;
//JS调用OC
- (void)addScriptMessageHandler:(NSString *)message observeValue:(nullable void (^)(WebModel *model))handler;

#pragma mark --- Cookies
//读取本地磁盘cookies
-(NSMutableArray *)ReadLocalDiskCookies;
//插入Cookie
- (void)setCookie:(NSHTTPCookie *)cookie;
//删除Cookie
- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))handler;
//删除域名下的Cookie
- (void)deleteWKCookiesByHost:(NSURL *_Nullable)host completionHandler:(nullable void (^)(void))handler;
//删除全部Cookies
-(void)clearAllCookies;
//清除HTML类型文件
- (void)clearHTMLCache;
//清除所有缓存（不包含Cookies）
- (void)clearWebCacheFinish:(void(^_Nullable)(BOOL finish,NSError * _Nullable error))handler;





// 返回上一级
- (void)goback;
// 下一级
- (void)goForward;
@end

NS_ASSUME_NONNULL_END
