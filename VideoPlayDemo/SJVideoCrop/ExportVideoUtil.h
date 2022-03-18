//
//  ExportVideoManager.h
//  VideoPlayDemo
//
//  Created by Mac027 on 2022/3/18.
//  Copyright © 2022 shengjie zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ExportVideoUtil : NSObject
+ (void)export:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(NSString *exportFilePath, NSError *error))complete;
@end

NS_ASSUME_NONNULL_END
