//
//  WKBaseWebView.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/28.
//

#import <Foundation/Foundation.h>

@class WebModel;

@interface registerURLSchemes : NSObject

//目前当app跨域请求时，app提示打开的 urlschemes，该类用于映射 urlschemes 和应用信息。

/**
 存储URLSchemes主要用于识别urlschemes的来源名字

 @params URLSchemes 列表
 */

+ (void)registerURLSchemes:(NSDictionary *)URLSchemes;
+ (void)registerURLSchemeModel:(NSArray<WebModel *>*)URLScheme;

/**
 需要注册的URLSchemes数据，需要时添加

 @return urlschemes 信息
 */
+ (NSDictionary *)urlschemes;

@end
