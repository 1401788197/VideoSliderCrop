//
//  SJCropCollectionCell.m
//  VideoPlayDemo
//
//  Created by shengjie zhang on 2019/3/27.
//  Copyright © 2019 shengjie zhang. All rights reserved.
//

#import "SJCropCollectionCell.h"

@implementation SJCropCollectionCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = self.contentView.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _imageView=imageView;
        self.backgroundColor=[UIColor clearColor];
        [self addSubview:imageView];
    }
    return self;
}
@end
