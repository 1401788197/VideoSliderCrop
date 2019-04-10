//
//  SJMediaInfoConfig.h
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/25.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SJMediaInfoConfig : NSObject
/**
 视频时长
 */
@property (nonatomic, assign) CGFloat sourceDuration;
/**
 开始时间
 */
@property (nonatomic, assign) CGFloat startTime;
/**
 结束时间
 */
@property (nonatomic, assign) CGFloat endTime;

/**
 最小时长
 */
@property (nonatomic, assign) CGFloat minDuration;

/**
 最大时长
 */
@property (nonatomic, assign) CGFloat maxDuration;
@end

NS_ASSUME_NONNULL_END
