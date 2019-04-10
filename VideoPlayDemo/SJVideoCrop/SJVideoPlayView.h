//
//  SJVideoPlayView.h
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/25.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class SJMediaInfoConfig;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CropPlayerStatus) {
    CropPlayerStatusPause,             // 结束或暂停
    CropPlayerStatusPlaying,           // 播放中
    CropPlayerStatusPlayingBeforeSeek  // 拖动之前是播放状态
};

@protocol SJVideoPlayViewDelegate <NSObject>

@required
-(void)SJVideoReadyToPlay;
@end

@interface SJVideoPlayView : UIView
- (id)initWithFrame:(CGRect)frame localUrl:(NSURL *)localUrl;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) CropPlayerStatus playerStatus;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) SJMediaInfoConfig *mediaConfig;
-(void)play;
@property (nonatomic,weak) id <SJVideoPlayViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
