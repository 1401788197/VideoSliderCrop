//
//  SJVideoPlayView.m
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/25.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import "SJVideoPlayView.h"
#import "SJMediaInfoConfig.h"
@interface SJVideoPlayView ()
{
    NSURL *_localUrl;
}
@end

@implementation SJVideoPlayView
-(id)initWithFrame:(CGRect)frame localUrl:(nonnull NSURL *)localUrl{
    _localUrl=localUrl;
    if (self=[super initWithFrame:frame]) {
         [self Config];
    }
    return self;
}
-(void)Config{
    NSURL *videoUrl = _localUrl;
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    self.userInteractionEnabled=YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playPauseClick)]];
}
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = _playerItem.status;
        if (status == AVPlayerItemStatusReadyToPlay) {
            if ([_delegate respondsToSelector:@selector(SJVideoReadyToPlay)]) {
                [_delegate SJVideoReadyToPlay];
            }
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            //            _cutInfo.sourceDuration = [_playerItem.asset avAssetVideoTrackDuration];
            //            if (_cutInfo.endTime == 0) {
            //                _cutInfo.startTime = 0.0;
            //                _cutInfo.endTime = _cutInfo.sourceDuration;
            //            }
            //            _playerStatus = AliyunCropPlayerStatusPlayingBeforeSeek;
            //            [self playVideo];
            //            [_thumbnailView loadThumbnailData];
            //            [self removeObserver:self forKeyPath:PlayerItemStatus];
            //            _KVOHasRemoved = YES;
        }else if (status == AVPlayerItemStatusFailed){
            NSLog(@"系统播放器无法播放视频=== %@",keyPath);
        }
    }
}
#pragma mark  播放完成
- (void)moviePlayDidEnd:(NSNotification *)notification {
    [self.player pause];
    AVPlayerItem *p = [notification object];
    [p seekToTime:CMTimeMake(self.mediaConfig.startTime * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}
-(void)play{
    [self.player play];
    self.playerStatus=CropPlayerStatusPlaying;
}
-(void)playPauseClick{
    if (self.playerStatus==CropPlayerStatusPause) {
        self.playerStatus=CropPlayerStatusPlaying;
        [self.player play];
    }else{
        self.playerStatus=CropPlayerStatusPause;
        [self.player pause];
    }
}
@end
