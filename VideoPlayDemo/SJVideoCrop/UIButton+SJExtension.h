//
//  UIButton+SJExtension.h
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/4/9.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SJExtension)

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

- (void)setEnlargeEdge:(CGFloat) size;

@end

NS_ASSUME_NONNULL_END
