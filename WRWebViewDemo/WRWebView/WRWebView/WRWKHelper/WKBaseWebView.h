//
//  WKBaseWebView.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKBaseWebView : UIViewController
@property (nonatomic, strong) UIBarButtonItem *backItem;   //返回按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;  //关闭按钮

/* 实现单例网页从此初始位置退出 */
@property (nonatomic, assign) NSInteger previousIndex;
@end

NS_ASSUME_NONNULL_END
