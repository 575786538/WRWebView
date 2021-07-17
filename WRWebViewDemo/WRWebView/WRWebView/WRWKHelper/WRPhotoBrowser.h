//
//  WRPhotoBrowser.h
//  WRWebView
//
//  Created by 吴瑞 on 2021/7/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface WRPhotoBrowser : NSObject
@property (nonatomic, retain) NSMutableArray *photos;

+ (instancetype)shareInstance;
- (void)loadPhotoBrowserShowIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
