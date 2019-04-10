//
//  SJVideoCropView.m
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/27.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import "SJVideoCropView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+SJExtension.h"
#import "SJMediaInfoConfig.h"
#import "SJCommon.h"
#import "SJCropCollectionCell.h"
#import "UIButton+SJExtension.h"
@interface SJVideoCropView ()<UIScrollViewDelegate>
{
    NSInteger _itemCount; //缩略图个数
    CGFloat _perSpWith;// 每秒占宽度
    CGFloat _itemWidth; //cellWidth
    CGFloat _FivecollectionWidth; // 15s 宽度
    CGFloat _maxScreenDuraion;//整个屏幕最大时长
    CGFloat _selectTime;//已选择的时间
    SJMediaInfoConfig *_mediaConfig;
    CGFloat _imageViewWith;//左右图片宽度
    UIColor *_itemBackgroundColor;//item整体颜色
    CGFloat _margion;//左右间距
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *durationLaber;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) UIImageView *imageViewLeft;
@property (nonatomic, strong) UIImageView *imageViewRight;
@property (nonatomic, strong) UIView *imageViewSelected;
@property (nonatomic, strong) UIButton *progressView;
@property (nonatomic, strong) UIImageView *topLineView;
@property (nonatomic, strong) UIImageView *underLineView;
@end

@implementation SJVideoCropView

-(instancetype)initWithFrame:(CGRect)frame mediaConfig:(SJMediaInfoConfig *)config{
     _mediaConfig=config;
    if (self=[super initWithFrame:frame] ) {
        [self BaseStting];
    }
    return self;
}
-(void)BaseStting{
        _itemBackgroundColor=kColorFromRGB(0XFBCD42);
        self.clipsToBounds=NO;
        _FivecollectionWidth=(self.width-60);
    
        _itemWidth=_FivecollectionWidth / 8.0;
        _imagesArray = [NSMutableArray array];
        if (_mediaConfig.sourceDuration<=15) {
        _mediaConfig.endTime=_mediaConfig.sourceDuration;
        _maxScreenDuraion=_mediaConfig.sourceDuration;
        _itemCount=8;
        }else{
            _mediaConfig.endTime=15;
            _maxScreenDuraion=15;
            _itemCount=_mediaConfig.sourceDuration/ (15.0/8.0);
        }
        _perSpWith=(_itemCount*_itemWidth)/_mediaConfig.sourceDuration;
    _imageViewWith = 20;
    _margion=(self.width -_mediaConfig.maxDuration*_perSpWith-_imageViewWith*2)/2.0;
    [self setupCollectionView];
    [self setupSubviews];
    self.userInteractionEnabled=YES;
}
- (void)setupCollectionView {
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(_itemWidth , 60);
    followLayout.minimumLineSpacing = 0;
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 35, self.width, 60) collectionViewLayout:followLayout];
    _collectionView.contentInset=UIEdgeInsetsMake(0, 30, 0, 30);
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.alwaysBounceHorizontal=YES;
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.delegate=(id<UICollectionViewDelegate>)self;
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    [_collectionView registerClass:[SJCropCollectionCell class] forCellWithReuseIdentifier:@"SJCropCollectionCell"];
    _collectionView.clipsToBounds=NO;
    [self addSubview:_collectionView];
}

- (void)setupSubviews {
    _durationLaber=[[UILabel alloc]initWithFrame:CGRectMake(15, 0, 70, 20)];
    _durationLaber.font=[UIFont systemFontOfSize:12];
    _durationLaber.backgroundColor=kColorFromRGB(0X123456);
    _durationLaber.textColor=[UIColor whiteColor];
    _durationLaber.textAlignment=NSTextAlignmentCenter;
    [self addSubview:_durationLaber];
    
    _imageViewLeft = [[UIImageView alloc] init];
    _imageViewLeft.contentMode=UIViewContentModeScaleAspectFit;
    _imageViewLeft.backgroundColor=_itemBackgroundColor;
    _imageViewLeft.frame = CGRectMake(_margion, _collectionView.y, _imageViewWith, _collectionView.height);
    _imageViewLeft.userInteractionEnabled = YES;
    _imageViewRight = [[UIImageView alloc] init];
    _imageViewRight.frame = CGRectMake(self.width - _imageViewWith-_margion, _collectionView.y, _imageViewWith, _collectionView.height);
    _imageViewRight.contentMode=UIViewContentModeScaleAspectFit;
    _imageViewRight.backgroundColor=_itemBackgroundColor;
    _imageViewRight.userInteractionEnabled = YES;
    _topLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_margion , _collectionView.y, self.width-2*_margion, 3)];
    _topLineView.backgroundColor = _itemBackgroundColor;
    _underLineView = [[UIImageView alloc]initWithFrame:CGRectMake(_topLineView.x, KMaxY(_collectionView)-3  , _topLineView.width, 3)];
    _underLineView.backgroundColor=_itemBackgroundColor;
    [self addSubview:_topLineView];
    [self addSubview:_underLineView];
    [self addSubview:_imageViewLeft];
    [self addSubview:_imageViewRight];
    _progressView = [[UIButton alloc] init];
    _progressView.backgroundColor=[UIColor whiteColor];
    [_progressView setRadius:3 borderColor:nil borderWidth:0];
    
    _progressView.bounds = CGRectMake(0, 0, 5,  70);
    _progressView.center = CGPointMake(0, _collectionView.centerY);
    _progressView.x=KMaxX(_imageViewLeft);
    _progressView.enabled=NO;
    _progressView.userInteractionEnabled=YES;
    [_progressView setEnlargeEdgeWithTop:0 right:30 bottom:0 left:30];
    [self addSubview:_progressView];
}
#pragma mark  加载视频截图
- (void)loadThumbnailData {
    _durationLaber.text=[NSString stringWithFormat:@"已选取%@s",[NSString stringWithFormat:@"%.0f",_mediaConfig.endTime - _mediaConfig.startTime]];
    _selectTime =_mediaConfig.endTime - _mediaConfig.startTime;
    CMTime startTime = kCMTimeZero;
    NSMutableArray *array = [NSMutableArray array];
    CMTime addTime = CMTimeMake(1000,1000);
    CGFloat d = _mediaConfig.sourceDuration / (_itemCount-1);
    int intd = d * 100;
    float fd = intd / 100.0;
    addTime = CMTimeMakeWithSeconds(fd, 1000);
    
    CMTime endTime = CMTimeMakeWithSeconds(_mediaConfig.sourceDuration, 1000);
    
    while (CMTIME_COMPARE_INLINE(startTime, <=, endTime)) {
        [array addObject:[NSValue valueWithCMTime:startTime]];
        startTime = CMTimeAdd(startTime, addTime);
    }
    
    // 第一帧取第0.1s   规避有些视频并不是从第0s开始的
    array[0] = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(0.1, 1000)];
    __weak __typeof(self) weakSelf = self;
    __block int index = 0;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *img = [[UIImage alloc] initWithCGImage:image];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.imagesArray addObject:img];
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [weakSelf.collectionView insertItemsAtIndexPaths:@[indexPath]];
                index++;
            });
        }
    }];
}
#pragma mark 调整进度条播放位置
- (void)updateProgressViewWithProgress:(CGFloat)progress {
    if (_imageViewSelected!=nil) {
        return;
    }
    CGFloat width = KMixX(_imageViewRight)-KMaxX(_imageViewLeft);
    CGFloat newX =KMaxX(_imageViewLeft)+ progress *width;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear |UIViewAnimationOptionAllowUserInteraction animations:^{
        weakSelf.progressView.x = newX;
    } completion:nil];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imagesArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SJCropCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJCropCollectionCell" forIndexPath:indexPath];
    cell.imageView.image=_imagesArray[indexPath.row];
    return cell;
}

- (AVAssetImageGenerator *)imageGenerator {
    if (!_imageGenerator) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_avAsset];
        _imageGenerator.appliesPreferredTrackTransform = YES;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.maximumSize = CGSizeMake(320, 320);
    }
    return _imageGenerator;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect adjustLeftRespondRect = _imageViewLeft.frame;
    CGRect adjustRightRespondRect = _imageViewRight.frame;
    CGRect adjustProgressRespondRect = CGRectMake(_progressView.frame.origin.x-30, _progressView.frame.origin.y, _progressView.frame.size.width+60, _progressView.frame.size.height) ;
    if (CGRectContainsPoint(adjustLeftRespondRect, point)) {
        _imageViewSelected = _imageViewLeft;
    } else if (CGRectContainsPoint(adjustRightRespondRect, point)) {
        _imageViewSelected = _imageViewRight;
    } else if (CGRectContainsPoint(adjustProgressRespondRect, point)) {
        _imageViewSelected = _progressView;
    }
    else {
        _imageViewSelected = nil;
    }
}
#pragma mark  手指滑动截取视频
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_imageViewSelected) return;
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint lp = [touch locationInView:_collectionView];
    CGPoint pp = [touch previousLocationInView:_collectionView];
    CGFloat offset = lp.x - pp.x;
    if (_imageViewSelected == _imageViewLeft) {
        CGRect frame = _imageViewLeft.frame;
        frame.origin.x += offset;
        if (frame.origin.x<=_margion) {
            offset+=(_margion-frame.origin.x);
            frame.origin.x=_margion;
        }
        if (frame.origin.x>=KMixX(_imageViewRight)-_perSpWith*_mediaConfig.minDuration-_imageViewWith) {
            offset-=frame.origin.x-(KMixX(_imageViewRight)-_perSpWith*_mediaConfig.minDuration-_imageViewWith);
            
            frame.origin.x=KMixX(_imageViewRight)-_perSpWith*_mediaConfig.minDuration-_imageViewWith;
        }
        CGFloat time = offset/_perSpWith;
        CGFloat left = _mediaConfig.startTime + time;
        _mediaConfig.startTime=left;
        _imageViewLeft.frame = frame;
        _progressView.x = KMaxX(_imageViewLeft);
        _mediaConfig.startTime = left;
        _durationLaber.text=[NSString stringWithFormat:@"已选取%@s",[NSString stringWithFormat:@"%.0f",_mediaConfig.endTime - _mediaConfig.startTime]];
        _selectTime =_mediaConfig.endTime - _mediaConfig.startTime;
        if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
            [_delegate cutBarDidMovedToTime:left];
        }
    } else if (_imageViewSelected == _imageViewRight) {
        
        CGRect frame = _imageViewRight.frame;
        frame.origin.x += offset;
        
        if (frame.origin.x>=self.width-30) {
            offset-=frame.origin.x-(self.width-30);
            frame.origin.x=self.width- 30;
        }
        
        if (frame.origin.x<=KMaxX(_imageViewLeft)+_perSpWith*_mediaConfig.minDuration) {
            offset+=(KMaxX(_imageViewLeft)+_perSpWith*_mediaConfig.minDuration)-frame.origin.x;
            frame.origin.x=KMaxX(_imageViewLeft)+_perSpWith*_mediaConfig.minDuration;
        }
        CGFloat time = offset/_perSpWith;
        CGFloat right = _mediaConfig.endTime + time;
        _mediaConfig.endTime = right;
        _imageViewRight.frame = frame;
        _progressView.x = KMixX(_imageViewRight);
        _durationLaber.text=[NSString stringWithFormat:@"已选取%@s",[NSString stringWithFormat:@"%.0f",_mediaConfig.endTime - _mediaConfig.startTime]];
        _selectTime =_mediaConfig.endTime - _mediaConfig.startTime;
        if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
            [_delegate cutBarDidMovedToTime:right];
        }
        //        }
    }else if(_imageViewSelected == _progressView){
        CGRect frame = _progressView.frame;
        frame.origin.x += offset;
        if (frame.origin.x<=KMaxX(_imageViewLeft)) {
            frame.origin.x=KMaxX(_imageViewLeft);
        }
        if (frame.origin.x>=KMixX(_imageViewRight)) {
            frame.origin.x=KMixX(_imageViewRight);
        }
        _progressView.frame = frame;
        if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
            CGFloat progresstime=   (KMixX(_progressView)-KMaxX(_imageViewLeft))/_perSpWith;
            [_delegate cutBarDidMovedToTime:_mediaConfig.startTime+progresstime];
        }
    }
    CGRect upFrame = _topLineView.frame;
    CGRect downFrame = _underLineView.frame;
    
    upFrame.origin.x = CGRectGetMaxX(_imageViewLeft.frame) - 3;
    downFrame.origin.x = upFrame.origin.x;
    
    upFrame.size.width = CGRectGetMinX(_imageViewRight.frame) - CGRectGetMaxX(_imageViewLeft.frame) + 6;
    downFrame.size.width = upFrame.size.width;
    
    _topLineView.frame = upFrame;
    _underLineView.frame = downFrame;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _imageViewSelected = nil;
    if ([_delegate respondsToSelector:@selector(cutBarTouchesDidEnd)]) {
        [_delegate cutBarTouchesDidEnd];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat time =(scrollView.contentOffset.x+30)/_perSpWith;
    if (time+(KMaxX(_imageViewLeft)-30)/_perSpWith<0) {
        return;
    }
    _mediaConfig.startTime = time+(KMaxX(_imageViewLeft)-30)/_perSpWith;
    _mediaConfig.endTime=_mediaConfig.startTime+_selectTime;
    if ([_delegate respondsToSelector:@selector(cutBarDidMovedToTime:)]) {
        [_delegate cutBarDidMovedToTime:_mediaConfig.startTime+self.siderTime];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"停止滚动了");
    if ([_delegate respondsToSelector:@selector(cutBarTouchesDidEnd)]) {
        [_delegate cutBarTouchesDidEnd];
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if ([_delegate respondsToSelector:@selector(cutBarTouchesDidEnd)]) {
            [_delegate cutBarTouchesDidEnd];
        }
    }
}
-(CGFloat)siderTime{
    return  (KMixX(_progressView)-KMaxX(_imageViewLeft))/_perSpWith;
}
@end
