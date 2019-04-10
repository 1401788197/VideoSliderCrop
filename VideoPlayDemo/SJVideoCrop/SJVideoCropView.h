//
//  SJVideoCropView.h
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/27.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJVideoCropViewDelegate <NSObject>

@optional

/**
 手指移动到的时间
 */
- (void)cutBarDidMovedToTime:(CGFloat)time;

/**
 松开手指
 */
- (void)cutBarTouchesDidEnd;
@end

@class SJMediaInfoConfig,AVAsset;
NS_ASSUME_NONNULL_BEGIN

@interface SJVideoCropView : UIView
-(instancetype)initWithFrame:(CGRect)frame mediaConfig:(SJMediaInfoConfig *)config;
@property (nonatomic, strong) AVAsset *avAsset;
@property (nonatomic,weak) id <SJVideoCropViewDelegate>delegate;
-(void)loadThumbnailData;
@property (nonatomic,assign) CGFloat siderTime;
/**
 更新进度
 
 @param progress 进度
 */
- (void)updateProgressViewWithProgress:(CGFloat)progress;
@end

NS_ASSUME_NONNULL_END
