//
//  WKWebView+Interactive.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/7/14.
//

#import <WebKit/WebKit.h>
#import "WebModel.h"
typedef void(^WebModelBlock)(WebModel * _Nullable model);

NS_ASSUME_NONNULL_BEGIN


@interface WKWebView (Interactive)
-(void)HandleMessage:(WKScriptMessage *)message WithuserContentController:(WKUserContentController *)userContentController WithModelArray:(NSMutableArray *)modelArray
 AndWebModel:(WebModelBlock)Model;
@end
NS_ASSUME_NONNULL_END
