//
//  UIAlertController+WKWebAlert.m
//  UIAlertController
//
//  Created by 吴瑞 on 2021/4/27.
//

#import "UIAlertController+WKWebAlert.h"
#import <WebKit/WebKit.h>
@interface UIViewController (WKWebAlert)

- (UIViewController *)ba_currentViewController;

@end

@implementation UIAlertController(WKWebAlert)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
+ (BOOL)isAlert{
    
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
            if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]]
                || [[subviews objectAtIndex:0] isKindOfClass:[UIAlertController class]])
                return YES;
    }
    return NO;
}


+ (void)WRlertWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)())completion
{
    UIAlertController*  showSecreetDefault = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ActionTrue = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        completion ? completion() : NULL;
    }];
    
    [showSecreetDefault addAction:ActionTrue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showSecreetDefault animated:YES completion:nil];
    });
}


+ (void)WRlertWithTitle:(NSString *)title
                message:(NSString *)message
           action1Title:(NSString *)action1Title
           action2Title:(NSString *)action2Title
                action1:(void (^)())action1
                action2:(void (^)())action2
{
    UIAlertController*  showSecreetDefault = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ActionOne = [UIAlertAction actionWithTitle:action1Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        action1 ? action1() : NULL;
    }];
    UIAlertAction *ActionTwo = [UIAlertAction actionWithTitle:action2Title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        action2 ? action2() : NULL;
    }];
    [showSecreetDefault addAction:ActionOne];
    [showSecreetDefault addAction:ActionTwo];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:showSecreetDefault animated:YES completion:nil];
    });
}



/**
 快速创建一个系统 普通 UIAlertController-ActionSheet
 
 @param viewController 显示的VC
 @param title title
 @param message message
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param popoverPresentationControllerBlock popoverPresentationControllerBlock description
 @param block block
 @return UIAlertController-ActionSheet
 */
+ (nonnull instancetype)ba_actionSheetShowInViewController:(nonnull UIViewController *)viewController
                                                     title:(nullable NSString *)title
                                                   message:(nullable NSString *)message
                                          buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                     buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
#if TARGET_OS_IOS
                        popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                                     block:(nullable BAKit_AlertControllerButtonActionBlock)block
{
    return [self ba_alertControllerShowInViewController:viewController
                                                  title:title
                                        attributedTitle:nil
                                                message:message
                                      attributedMessage:nil
                                         preferredStyle:UIAlertControllerStyleActionSheet
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:nil
                              textFieldPlaceholderArray:nil
                      textFieldConfigurationActionBlock:nil
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:popoverPresentationControllerBlock
#endif
                                                  block:block];
}



+ (instancetype)ba_alertControllerShowInViewController:(UIViewController *)viewController
                                                 title:(NSString *)title
                                       attributedTitle:(nullable NSMutableAttributedString *)attributedTitle
                                               message:(NSString *)message
                                     attributedMessage:(nullable NSMutableAttributedString *)attributedMessage
                                        preferredStyle:(UIAlertControllerStyle)preferredStyle
                                      buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                 buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
                         buttonEnabledNoWithTitleArray:(NSArray <NSString *> *_Nullable)buttonEnabledNoWithTitleArray
                             textFieldPlaceholderArray:(NSArray <NSString *> *_Nullable)textFieldPlaceholderArray
                     textFieldConfigurationActionBlock:(nullable BAKit_AlertControllerTextFieldConfigurationActionBlock)textFieldConfigurationActionBlock
#if TARGET_OS_IOS
                    popoverPresentationControllerBlock:(void(^)(UIPopoverPresentationController *popover))popoverPresentationControllerBlock
#endif
                                                 block:(BAKit_AlertControllerButtonActionBlock)block
{
    UIAlertController *strongController = [self alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:preferredStyle];
    
    __weak UIAlertController *alertController = strongController;
    
    if (buttonTitleArray)
    {
        for (NSUInteger i = 0; i < buttonTitleArray.count; i++)
        {
            NSString *buttonTitle = buttonTitleArray[i];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               if (block)
                                                               {
                                                                   block(alertController, action, i);
                                                               }
                                                           }];
            [alertController addAction:action];
            
            for (NSInteger j = 0; j < buttonEnabledNoWithTitleArray.count; j ++)
            {
                if ([buttonEnabledNoWithTitleArray[j] isEqualToString:buttonTitle])
                {
                    action.enabled = NO;
                }
            }
            
            /*
             if (buttonTitleColorArray)
             {
                 [strongController setAlertWithAlert:strongController
                              mutableAttributedTitle:attributedTitle
                            mutableAttributedMessage:attributedMessage
                                              Action:action
                                    buttonTitleColor:buttonTitleColorArray[i]];
             }
             */
        }
    }
    if (textFieldPlaceholderArray)
    {
        for (NSInteger i = 0; i < textFieldPlaceholderArray.count; i++)
        {
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                textField.placeholder = textFieldPlaceholderArray[i];
                if (textFieldConfigurationActionBlock)
                {
                    textFieldConfigurationActionBlock(textField, i);
                }
            }];
        }
    }
    
    if (preferredStyle == UIAlertControllerStyleActionSheet)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取 消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [alertController addAction:action];
    }
    
#if TARGET_OS_IOS
    if (popoverPresentationControllerBlock)
    {
        popoverPresentationControllerBlock(alertController.popoverPresentationController);
    }
#endif
    
    [viewController.ba_currentViewController presentViewController:alertController animated:YES completion:nil];
    
    return alertController;
}


- (void)setAlertWithAlert:(UIAlertController * __nonnull )alert
   mutableAttributedTitle:(NSMutableAttributedString *)mutableAttributedTitle
 mutableAttributedMessage:(nullable NSMutableAttributedString *)mutableAttributedMessage
                   Action:(UIAlertAction * __nonnull )action
         buttonTitleColor:(UIColor *)buttonTitleColor
{
    /*! 1、首先获得对应的属性 */
    //    NSArray *propertysListArray = [[UIAlertController class] ba_propertysList];
    //    NSLog(@"1、获取【UIAlertController】所有的属性名：%@", propertysListArray);
    
    /*! 2、获得成员变量 */
    NSArray *ivarListArray = [[UIAlertAction class] ba_ivarList];
    //    NSLog(@"2、获取【UIAlertController】所有的成员变量：%@", ivarListArray);
    
    for (NSInteger i = 0; i < ivarListArray.count; i++)
    {
        NSString *ivarName = ivarListArray[i];
        if ([ivarName isEqualToString:@"_titleTextColor"])
        {
            [action setValue:buttonTitleColor forKey:@"titleTextColor"];
        }
    }
    
    /*! 3、改变显示提示字体颜色 */
    NSArray *propertysListArray2 = [[UIAlertController class] ba_ivarList];
    //    NSLog(@"3、获取【UIAlertController】所有的成员变量：%@", propertysListArray2);
    for (NSInteger i = 0; i < propertysListArray2.count; i++)
    {
        NSString *ivarName = propertysListArray2[i];
        if ([ivarName isEqualToString:@"_attributedTitle"])
        {
            [alert setValue:mutableAttributedTitle forKey:@"attributedTitle"];
        }
        if ([ivarName isEqualToString:@"_attributedMessage"])
        {
            [alert setValue:mutableAttributedMessage forKey:@"attributedMessage"];
        }
    }
}

/** 调用JS的alert()方法 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    
    [self WRpresentViewController:alertController animated:YES];
}

/** 调用JS的confirm()方法 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(nonnull NSString *)message initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message ? message : @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    
    [self WRpresentViewController:alertController animated:YES];
}

/** 调用JS的prompt()方法 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(nonnull NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(nonnull WKFrameInfo *)frame completionHandler:(nonnull void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self WRpresentViewController:alertController animated:YES];
}

/** webview关闭时回调 */
- (void)webViewDidClose:(WKWebView *)webView
{
    
}
- (void)WRpresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag{
    
    __weak typeof(self)weekSelf = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [weekSelf presentViewController:viewControllerToPresent animated:YES completion:nil];
    });
}

#pragma clang diagnostic pop

@end




















@implementation UIViewController (WKWebAlert)

- (UIViewController *)ba_currentViewController{
    UIViewController *topVC = self;
    UIViewController *above;
    while ((above = topVC.presentedViewController)) {
        topVC = above;
    }
    return topVC;
}

@end
