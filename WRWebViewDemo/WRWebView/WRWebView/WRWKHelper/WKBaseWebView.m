//
//  WKBaseWebView.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/27.
//

#import "WKBaseWebView.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface WKBaseWebView ()<UIGestureRecognizerDelegate>
@property (assign, nonatomic) BOOL animatedFlag;

@end

@implementation WKBaseWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationController.navigationBar.translucent = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
}
#pragma mark -- NaviBarItem
- (UIStatusBarStyle)preferredStatusBarStyle{
    __weak typeof(self)weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weakSelf.view.backgroundColor = [UIColor colorWithRed:4/255.0 green:176/255.0 blue:250/255.0 alpha:1];
    });
    return UIStatusBarStyleLightContent;
}
- (UIBarButtonItem *)backItem{
    if (!_backItem)
    { _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"BACKImage"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:@"  返回" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        btn.frame = CGRectMake(0, 0, 58, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.childViewControllers.count == 1) { //当只有一个自控制器时不可滑动

        return NO;
    }

    return YES;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)popToBackForwardListItem:(WKBackForwardListItem *)item WebView:(WKWebView *)webview{
    
    [webview goToBackForwardListItem:item];
}


@end
