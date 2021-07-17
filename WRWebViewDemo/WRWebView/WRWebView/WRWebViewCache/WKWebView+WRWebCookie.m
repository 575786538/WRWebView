//
//  WKWebView+WRWebBookie.m
//  WRWebView
//
//  Created by 吴瑞 on 2021/4/29.
//

#import "WKWebView+WRWebCookie.h"
#import <WebKit/WKHTTPCookieStore.h>
static NSString* const WRWKCookiesKey = @"org.skyfox.WRWKShareInstanceCookies";

@implementation WKWebView (WRWebCookie)
// 获取本地磁盘的cookies
- (NSMutableArray *)obtainHTTPCookieStorage{
    NSMutableArray *cookiesArray = [NSMutableArray array];
    NSHTTPCookieStorage *obtainCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in obtainCookie.cookies) {
        [cookiesArray addObject:cookie];
    }
    //获取自定义存储的cookies
    NSMutableArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: WRWKCookiesKey]];
    //删除过期cookies
    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = [cookies objectAtIndex:i];
        if (!cookie.expiresDate) {
            [cookiesArray addObject:cookie];
        }
        if ([cookie.expiresDate compare:self.currentTime]) {
            [cookiesArray addObject:cookie];
        }else{
            [cookies removeObject:cookie];
            i--;
        }
    }
    //@@@@
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:cookies requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:WRWKCookiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"cookies:%@",cookiesArray);
    return cookiesArray;
    
}
//同步cookies
-(void)syncCookiesToWKHTTPCookieStore:(WKHTTPCookieStore *)cookieStroe API_AVAILABLE(macosx(10.13), ios(11.0)){
    NSMutableArray *cookieArray = [self obtainHTTPCookieStorage];
    if (cookieArray.count == 0) {
        return;
    }
    for (NSHTTPCookie *cookid  in cookieArray) {
        [cookieStroe setCookie:cookid completionHandler:nil];
    }
}


// 插入cookies存储于磁盘
- (void)insertCookie:(NSHTTPCookie *)cookie{
    WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
    [cookieStore setCookie:cookie completionHandler:nil];
    NSHTTPCookieStorage *shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [shareCookie setCookie:cookie];
    NSMutableArray *TempCookies = [NSMutableArray array];
    NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: WRWKCookiesKey]];

    for (int i = 0; i < localCookies.count; i++) {
        NSHTTPCookie *TempCookie = [localCookies objectAtIndex:i];
        if ([cookie.name isEqualToString:TempCookie.name] &&
            [cookie.domain isEqualToString:TempCookie.domain]) {
            [localCookies removeObject:TempCookie];
            i--;
            break;
        }
    }
    [TempCookies addObjectsFromArray:localCookies];
    [TempCookies addObject:cookie];
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: TempCookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:WRWKCookiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)clearAllCookies{
    NSSet *websiteDataTypes = [NSSet setWithObject:WKWebsiteDataTypeCookies];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{}];
    //删除NSHTTPCookieStorage中的cookies
    NSHTTPCookieStorage *NSCookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [NSCookiesStore removeCookiesSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: @[]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:WRWKCookiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)deleteWKCookie:(NSHTTPCookie *)cookie completionHandler:(nullable void (^)(void))handler{
    //删除WKHTTPCookieStore中的cookies
    WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
    [cookieStore deleteCookie:cookie completionHandler:nil];
    //删除NSHTTPCookieStorage中的cookie
    NSHTTPCookieStorage *cookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookiesStore deleteCookie:cookie];
    
    //删除磁盘中的cookie unarchivedObjectOfClass:fromData:error @@@@
    
    NSMutableArray *localCookies = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:[[NSUserDefaults standardUserDefaults] objectForKey: WRWKCookiesKey] error:nil];
    
    for (int i = 0; i < localCookies.count; i++) {
        NSHTTPCookie *tempCookie = [localCookies objectAtIndex:i];
        if ([cookie.domain isEqualToString:tempCookie.domain]) {
            [localCookies removeObject:tempCookie];
            i--;
        }
    }
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:localCookies requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:WRWKCookiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    handler ? handler() : NULL;
}
- (void)deleteWKCookiesByHost:(NSURL *)host completionHandler:(nullable void (^)(void))handler{
    //删除WKHTTPCookieStore中的cookies
    WKHTTPCookieStore *cookieStore = self.configuration.websiteDataStore.httpCookieStore;
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * cookies) {
        
        NSArray *WKCookies = cookies;
        for (NSHTTPCookie *cookie in WKCookies) {
            
            NSURL *domainURL = [NSURL URLWithString:cookie.domain];
            if ([domainURL.host isEqualToString:host.host]) {
                [cookieStore deleteCookie:cookie completionHandler:nil];
            }
        }
    }];
    
    //删除NSHTTPCookieStorage中的cookies
    NSHTTPCookieStorage *NSCookiesStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *NSCookies = NSCookiesStore.cookies;
    for (NSHTTPCookie *cookie in NSCookies) {
        
        NSURL *domainURL = [NSURL URLWithString:cookie.domain];
        if ([domainURL.host isEqualToString:host.host]) {
            [NSCookiesStore deleteCookie:cookie];
        }
    }
    
    //删除磁盘中的cookies
    NSMutableArray *localCookies =[NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: WRWKCookiesKey]];
    for (int i = 0; i < localCookies.count; i++) {
        
        NSHTTPCookie *TempCookie = [localCookies objectAtIndex:i];
        NSURL *domainURL = [NSURL URLWithString:TempCookie.domain];
        if ([host.host isEqualToString:domainURL.host]) {
            [localCookies removeObject:TempCookie];
            i--;
            break;
        }
    }
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: localCookies];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData forKey:WRWKCookiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    handler ? handler() : nil;
}
- (void)clearHTMLCache{
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/
    NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    /*
     * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData
     */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    NSError *error;
    /* 取得目录下所有的文件，取得文件数组*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:webKitFolderInCachesfs error:&error];
    /* 遍历文件组成的数组*/
    NSLog(@"fileList:%@",fileList);
    for(NSString * fileName in fileList){
        /* 定位每个文件的位置*/
        NSString * path = [[NSBundle bundleWithPath:webKitFolderInCachesfs] pathForResource:fileName ofType:@""];
        /* 将文件转换为NSData类型的数据*/
        NSData * fileData = [NSData dataWithContentsOfFile:path];
        /* 如果FileData的长度大于2，说明FileData不为空*/
        if(fileData.length >2){
            /* 创建两个用于显示文件类型的变量*/
            int char1 =0;
            int char2 =0;
            
            [fileData getBytes:&char1 range:NSMakeRange(0,1)];
            [fileData getBytes:&char2 range:NSMakeRange(1,1)];
            /* 拼接两个变量*/
            NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
            /* 如果该文件前四个字符是6033，说明是Html文件，删除掉本地的缓存*/
            if([numStr isEqualToString:@"6033"]){
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",webKitFolderInCachesfs,fileName]error:&error];
                continue;
            }
        }
    }
    NSLog(@"down");
}
// JS获取domain的cookie
- (WKUserScript *)searchCookieForUserScriptWithDomain:(NSString *)domain{
    NSString *cookie = [self jsCookieStringWithDomain:domain];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: cookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    return cookieScript;
}
- (NSString *)jsCookieStringWithDomain:(NSString *)domain{
    NSMutableString *cookieSting = [NSMutableString string];
    NSArray *cookieArr = [self obtainHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieArr) {
        if ([cookie.domain containsString:domain]) {
            [cookieSting appendString:[NSString stringWithFormat:@"document.cookie = '%@=%@';",cookie.name,cookie.value]];
        }
    }
    return cookieSting;
}

//PHP 获取domain的cookie
- (NSString *)phpCookieStringWithDomain:(NSString *)domain
{
    NSMutableString *cookieSting =[NSMutableString string];
    NSArray *cookieArr = [self obtainHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieArr) {
        if ([cookie.domain containsString:domain]) {
            [cookieSting appendString:[NSString stringWithFormat:@"%@ = %@;",cookie.name,cookie.value]];
        }
    }
    if (cookieSting.length > 1)[cookieSting deleteCharactersInRange:NSMakeRange(cookieSting.length - 1, 1)];
    
    return (NSString *)cookieSting;
}


- (NSDate *)currentTime
{
    return [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
