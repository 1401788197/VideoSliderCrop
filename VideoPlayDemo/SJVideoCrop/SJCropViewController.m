//
//  SJCropViewController.m
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/4/9.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import "SJCropViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SJVideoPlayView.h"
#import "SJVideoCropView.h"
#import "SJMediaInfoConfig.h"
#import "UIView+SJExtension.h"
#import "SJCommon.h"

@interface SJCropViewController ()<SJVideoCropViewDelegate,SJVideoPlayViewDelegate>
{
    NSURL *_localVideoUrl;
    SJMediaInfoConfig *_mediaConfig;
}
@property (nonatomic, strong) SJVideoPlayView *palyView;
@property (nonatomic, strong) SJVideoCropView *cropView;
@property (nonatomic, strong) id timeObserver;

@end

@implementation SJCropViewController

-(SJVideoPlayView *)palyView{
    if (!_palyView) {
        _palyView=[[SJVideoPlayView alloc]initWithFrame:self.view.bounds localUrl:_localVideoUrl];
        _palyView.delegate=self;
    }
    return _palyView;
}
-(SJVideoCropView *)cropView{
    if (!_cropView) {
        _cropView=[[SJVideoCropView alloc]initWithFrame:CGRectMake(0, self.view.height - 25 - 95 , self.view.width, 95) mediaConfig:_mediaConfig];
        _cropView.avAsset=[AVAsset assetWithURL:_localVideoUrl];
        _cropView.delegate=self;
    }
    return _cropView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    _localVideoUrl=[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"video.mp4" ofType:nil]];
    [self setConfig];
    [self.view addSubview:self.palyView];
    [self.view addSubview:self.cropView];
    self.palyView.mediaConfig=_mediaConfig;
    self.palyView.playerItem.forwardPlaybackEndTime = CMTimeMake(_mediaConfig.endTime * 1000, 1000);
}
-(void)setConfig{
    SJMediaInfoConfig  *config = [[SJMediaInfoConfig alloc]init];
    config.startTime=0;
    config.endTime=15;
    config.minDuration=3;
    config.maxDuration=15;
    config.sourceDuration =[self avAssetVideoTrackDuration:self.palyView.playerItem.asset];
    _mediaConfig=config;
}
#pragma mark  手指滚动
- (void)cutBarDidMovedToTime:(CGFloat)time {
    if (time<=0) {
        return;
    }
    if (self.palyView.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.palyView.player seekToTime:CMTimeMake(time * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        if (self.palyView.playerStatus == CropPlayerStatusPlaying) {
            [self.palyView.player pause];
            self.palyView.playerStatus = CropPlayerStatusPlayingBeforeSeek;
            if (_timeObserver){
                [self.palyView.player removeTimeObserver:_timeObserver];
                _timeObserver=nil;
            }
        }
    }
}
#pragma mark 手指滚动结束
- (void)cutBarTouchesDidEnd {
    self.palyView.playerItem.forwardPlaybackEndTime = CMTimeMake(_mediaConfig.endTime * 1000, 1000);
    if (self.palyView.playerStatus == CropPlayerStatusPlayingBeforeSeek) {
        [self playVideo];
    }
}
- (void)playVideo {
    if (self.palyView.playerStatus == CropPlayerStatusPlayingBeforeSeek) {
        CGFloat time = (self.cropView.siderTime+_mediaConfig.startTime);
        if (self.cropView.siderTime+1>=_mediaConfig.endTime-_mediaConfig.startTime) {
            time=_mediaConfig.startTime;
        }
        [self.palyView.player seekToTime:CMTimeMake(time* 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
    [self.palyView.player play];
    self.palyView.playerStatus = CropPlayerStatusPlaying;
    
    if (_timeObserver){
        [self.palyView.player removeTimeObserver:_timeObserver];
        _timeObserver=nil;
    }
    //    return;
    __weak __typeof(self) weakSelf = self;
    
    _timeObserver = [self.palyView.player                addPeriodicTimeObserverForInterval:
                     CMTimeMake(1, 10)
                                                                                      queue:dispatch_get_main_queue()
                                                                                 usingBlock:^(CMTime time) {
                                                                                     __strong __typeof(self) strong = weakSelf;
                                                                                     CGFloat crt = CMTimeGetSeconds(time);
                                                                                     if (self.palyView.playerStatus == CropPlayerStatusPlayingBeforeSeek||self.palyView.playerStatus==CropPlayerStatusPause) {
                                                                                         return ;
                                                                                     }
                                                                                     [strong.cropView updateProgressViewWithProgress:(crt-self->_mediaConfig.startTime)/(self->_mediaConfig.endTime-self->_mediaConfig.startTime)];
                                                                                 }];
}
-(void)SJVideoReadyToPlay{
    self.palyView.playerStatus =CropPlayerStatusPlayingBeforeSeek;
    [self playVideo];
    [self.cropView loadThumbnailData];
}
- (CGFloat)avAssetVideoTrackDuration:(AVAsset *)asset {
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count) {
        AVAssetTrack *track = videoTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count) {
        AVAssetTrack *track = audioTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    return -1;
}

@end
