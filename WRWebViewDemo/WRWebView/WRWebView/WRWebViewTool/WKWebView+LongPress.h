//
//  WKWebView+LongPress.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/7/15.
//

#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN


@interface WKWebView (LongPress)<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *LongPress;

/**
 添加长按手势
 */
- (void)addGestureRecognizerObserverWebElements:(void(^)(BOOL longpress))Event;

@end

NS_ASSUME_NONNULL_END
