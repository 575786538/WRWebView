//
//  WKWebView+Interactive.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/7/14.
//

#import "WKWebView+Interactive.h"

@implementation WKWebView (Interactive)

-(void)HandleMessage:(WKScriptMessage *)message WithuserContentController:(WKUserContentController *)userContentController WithModelArray:(NSMutableArray *)modelArray
         AndWebModel:(WebModelBlock)Model{
    for (WebModel *model in modelArray) {
        if ([model.message_name isEqualToString:message.name]) {
            model.message = message;
            model.userContentController = userContentController;
            model.MessageHandler?model.MessageHandler(model):nil;
        }
    }
    
}

@end
