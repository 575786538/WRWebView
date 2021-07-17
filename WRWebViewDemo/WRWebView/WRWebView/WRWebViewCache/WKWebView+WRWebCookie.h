//
//  WKWebView+WRWebBookie.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/29.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (WRWebCookie)
/** ios11 同步cookies */
- (void)syncCookiesToWKHTTPCookieStore:(WKHTTPCookieStore *)cookieStroe API_AVAILABLE(macosx(10.13), ios(11.0));

/** 插入cookies存储于磁盘 */
- (void)insertCookie:(NSHTTPCookie *)cookie;

/** 获取本地磁盘的cookies */
- (NSMutableArray *)obtainHTTPCookieStorage;

/** 删除所有的cookies */
- (void)clearAllCookies;

/** 删除某一个cookies */
- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))handler;
- (void)deleteWKCookiesByHost:(NSURL *)host completionHandler:(nullable void (^)(void))handler;

/** js获取domain的cookie */
- (WKUserScript *)searchCookieForUserScriptWithDomain:(NSString *)domain;

/** PHP 获取domain的cookie */
- (NSString *)phpCookieStringWithDomain:(NSString *)domain;
//清除HTML文件
- (void)clearHTMLCache;

@end

NS_ASSUME_NONNULL_END
