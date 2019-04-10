//
//  UIView+SJExtension.h
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/27.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SJExtension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
- (void)setRadius:(float)radius borderColor:(nullable UIColor* )color borderWidth:(CGFloat)width;
- (void)setRadius:(float)radius  corners: (UIRectCorner)corners;
- (void)setHalfRadius;
@end

NS_ASSUME_NONNULL_END
