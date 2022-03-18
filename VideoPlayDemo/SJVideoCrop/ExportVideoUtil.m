//
//  ExportVideoManager.m
//  VideoPlayDemo
//
//  Created by Mac027 on 2022/3/18.
//  Copyright © 2022 shengjie zhang. All rights reserved.
//

#import "ExportVideoUtil.h"


@implementation ExportVideoUtil
+ (void)export:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(NSString *exportFilePath, NSError *error))complete
{
	NSString *exportFilePath =[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mp4",[[NSDate date] timeIntervalSince1970]]];

	AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough]; //   AVAssetExportPresetHighestQuality

	NSURL *exportFileUrl = [NSURL fileURLWithPath:exportFilePath];

	exportSession.outputURL = exportFileUrl;
	exportSession.outputFileType = AVFileTypeMPEG4;
	exportSession.timeRange = range;

	[exportSession exportAsynchronouslyWithCompletionHandler:^{
	         BOOL suc = NO;
	         switch ([exportSession status]) {
		 case AVAssetExportSessionStatusFailed:
			 NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
			 break;
		 case AVAssetExportSessionStatusCancelled:
			 NSLog(@"Export canceled");
			 break;

		 case AVAssetExportSessionStatusCompleted: {
			 NSLog(@"Export completed");
			 suc = YES;
		 }
		 break;

		 default:
			 NSLog(@"Export other");
			 break;
		 }
	         if (complete) {
			 complete(suc?exportFilePath:nil, suc?nil:exportSession.error);
			 if (!suc) {
				 [exportSession cancelExport];
			 }
		 }
	 }];
}
@end
