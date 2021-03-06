//
//  WRWebNavigationView.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import "WRWebNavigationView.h"
#import "UIAlertController+WKWebAlert.h"
@implementation WRWebNavigationView
+ (instancetype)shareInstance{
    
    static WRWebNavigationView *Nav = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Nav = [[WRWebNavigationView alloc]init];
    });
    return Nav;
}
- (void)defaultMenuShowInViewController:(nonnull UIViewController *)viewController
                                                  title:(nullable NSString *)title
                                                message:(nullable NSString *)message
                                       buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                  buttonTitleColorArray:(nullable NSArray<UIColor *> *)buttonTitleColorArray
                     popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
                                                  block:(nullable BAKit_AlertControllerButtonActionBlock)block
{
    
    [UIAlertController ba_actionSheetShowInViewController:viewController
                                                    title:title
                                                  message:message
                                         buttonTitleArray:buttonTitleArray
                                    buttonTitleColorArray:buttonTitleColorArray
                       popoverPresentationControllerBlock:popoverPresentationControllerBlock
                                                    block:block];
    
}

- (void)customMenuShowInViewController:(UIViewController *)viewController
                                 title:(nullable NSString *)title
                               message:(nullable NSString *)message
                      buttonTitleArray:(nullable NSArray *)buttonTitleArray
                 buttonTitleColorArray:(nullable NSArray<UIColor *> *)buttonTitleColorArray
    popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
                                 block:(nullable BAKit_AlertControllerButtonActionBlock)block{
    [UIAlertController ba_actionSheetShowInViewController:viewController
                                                    title:title
                                                  message:message
                                         buttonTitleArray:buttonTitleArray
                                    buttonTitleColorArray:buttonTitleColorArray
                       popoverPresentationControllerBlock:popoverPresentationControllerBlock
                                                    block:block];
    
}

@end
