//
//  WRWebNavigationView.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import <Foundation/Foundation.h>
#import "UIAlertController+WKWebAlert.h"

typedef NS_ENUM(NSInteger,WRWebViewNavType){
    
    OPEN_SAFARI,
    COPY_URL,
    RELOAD_URL,
    SHARE_URL,
};

NS_ASSUME_NONNULL_BEGIN
@interface WRWebNavigationView : NSObject
+ (instancetype)shareInstance;
@property (nonatomic, assign) BOOL defaultType;
/**
   默认菜单栏展示

 @param viewController 展示图层
 @param title 标题
 @param message 信息
 @param buttonTitleArray 按钮标题
 @param buttonTitleColorArray 按钮标题颜色
 @param popoverPresentationControllerBlock 弹框完毕回到
 @param block 响应回调
 */
- (void)defaultMenuShowInViewController:(nonnull UIViewController *)viewController
                                                  title:(nullable NSString *)title
                                                message:(nullable NSString *)message
                                       buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                  buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
#if TARGET_OS_IOS
                      popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                                  block:(nullable BAKit_AlertControllerButtonActionBlock)block;


#pragma clang diagnostic pop

- (void)customMenuShowInViewController:(nonnull UIViewController *)viewController
                                  title:(nullable NSString *)title
                                message:(nullable NSString *)message
                       buttonTitleArray:(nullable NSArray *)buttonTitleArray
                  buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
#if TARGET_OS_IOS
     popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                  block:(nullable BAKit_AlertControllerButtonActionBlock)block;


#pragma clang diagnostic pop
@end

NS_ASSUME_NONNULL_END
