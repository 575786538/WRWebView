//
//  WKBaseWebView.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/28.
//

#import <Foundation/Foundation.h>

@interface NSURL (WRTool)



/**
   组合请求参数

 @param baseURL 请求链接，？之前部分
 @param params ？之后的参数
 @return 完整的请求链接
 */
+ (NSURL *)generateURL:(NSString*)baseURL params:(NSDictionary*)params;


/**
   打开跨域请求

 @param URL 请求链接
 */
+ (void)openURL:(NSURL *)URL;

+ (void)safariOpenURL:(NSURL *)URL;

@end
