//
//  WebModel.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/28.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface WebModel : NSObject
@property (nonatomic,copy) NSString *scheme;
@property (nonatomic,copy) NSString *appstoreURL;
@property (nonatomic,copy) NSString *appid;
@property (nonatomic,copy) NSString *displayName;


@property (nonatomic,strong) NSString *message_name;
@property (nonatomic,strong) WKUserContentController *userContentController;
@property (nonatomic,strong) WKScriptMessage *message;
@property (nonatomic, copy) void(^MessageHandler)(WebModel *model);


@end

NS_ASSUME_NONNULL_END
