//
//  DemoViewController.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/5/5.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    _webView = [WRWebView shareInstance];
    _webView.progressTintColor = [UIColor blueColor];
    [_webView loadLocalHTMLWithFileName:@"main"];// 加载本地网页
    [self.navigationController pushViewController:_webView animated:YES];
    __weak typeof(self) weakSelf = self;

    [_webView addScriptMessageHandler:@"A" observeValue:^(WebModel * _Nonnull model) {
        [weakSelf OCCallJS];
    }];
    
    [_webView addScriptMessageHandler:@"B" observeValue:^(WebModel * _Nonnull model) {
        NSLog(@"name:%@",model.message.name);
        [weakSelf.webView loadRequestURL:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.sina.cn"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0f]];
    }];
    [_webView addScriptMessageHandler:@"webViewApp" observeValue:^(WebModel * _Nonnull model) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"什么❓" message:@"我竟然被调用了" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"没错" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           }];
        [alert addAction:conform];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    }];
    [_webView addScriptMessageHandler:@"C" observeValue:^(WebModel * _Nonnull model) {
        [weakSelf.webView clearAllCookies];
        [weakSelf.webView clearHTMLCache];
        [weakSelf.webView clearWebCacheFinish:^(BOOL finish, NSError * _Nullable error) {
            if (finish == YES) {
                NSLog(@"成功");
            }
        }];
    }];
}



#pragma mark - OC 调用 JS

-(void)OCCallJS{
    [[WRWebView shareInstance] OCCallJS:@"alert('OC调用JS成功 🐂🍺')" handler:^(id  _Nonnull response, NSError * _Nonnull error) {
        
    }];
}
/*
 //JS调用OC
 [_webView addScriptMessageHandler:@"webViewApp" observeValue:^(WebModel * _Nonnull model) {
     NSLog(@"name:%@",model.name);
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"什么❓" message:@"我竟然被调用了" preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *conform = [UIAlertAction actionWithTitle:@"没错" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
     [alert addAction:conform];
     [weakSelf presentViewController:alert animated:YES completion:nil];
     
     
 }];
 */
@end
