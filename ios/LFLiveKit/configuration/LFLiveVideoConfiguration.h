//
//  LFLiveVideoConfiguration.h
//  LFLiveKit
//
//  Created by LaiFeng on 16/5/20.
//  Copyright © 2016年 LaiFeng All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 视频分辨率(都是16：9 当此设备不支持当前分辨率，自动降低一级)
typedef NS_ENUM (NSUInteger, LFLiveVideoSessionPreset){
    /// 低分辨率
    LFCaptureSessionPreset320x240 = 0,

    LFCaptureSessionPreset640x480 = 1,
    /// 中分辨率
    LFCaptureSessionPreset960x540 = 2,
    /// 高分辨率
    LFCaptureSessionPreset1280x720 = 3,
    /// 中分辨率
    LFCaptureSessionPreset1920x1080 = 4,
    /// 高分辨率
    LFCaptureSessionPreset3840x2160 = 5
};

/// 视频质量
typedef NS_ENUM (NSUInteger, LFLiveVideoQuality){
    /// 分辨率： 360 *640 帧数：15 码率：500Kps
    LFLiveVideoQuality_1 = 0,
    /// 分辨率： 360 *640 帧数：24 码率：800Kps
    LFLiveVideoQuality_2 = 1,
    /// 分辨率： 360 *640 帧数：30 码率：800Kps
    LFLiveVideoQuality_3 = 2,
    /// 分辨率： 540 *960 帧数：15 码率：800Kps
    LFLiveVideoQuality_4 = 3,
    /// 分辨率： 540 *960 帧数：24 码率：800Kps
    LFLiveVideoQuality_5 = 4,
    /// 分辨率： 540 *960 帧数：30 码率：800Kps
    LFLiveVideoQuality_6 = 5,

    LFLiveVideoQuality_Default = LFLiveVideoQuality_1
};

@interface LFLiveVideoConfiguration : NSObject<NSCoding, NSCopying>

/// 默认视频配置
+ (instancetype)defaultConfiguration;
/// 视频配置(质量)
+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality;

/// 视频配置(质量 & 是否是横屏)
+ (instancetype)defaultConfigurationForQuality:(LFLiveVideoQuality)videoQuality outputImageOrientation:(UIInterfaceOrientation)outputImageOrientation;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// 视频的分辨率，宽高务必设定为 2 的倍数，否则解码播放时可能出现绿边(这个videoSizeRespectingAspectRatio设置为YES则可能会改变)
@property (nonatomic, assign) CGSize videoSize;

/// 输出图像是否等比例,默认为NO
@property (nonatomic, assign) BOOL videoSizeRespectingAspectRatio;

/// 视频输出方向
@property (nonatomic, assign) UIInterfaceOrientation outputImageOrientation;

/// 自动旋转(这里只支持 left 变 right  portrait 变 portraitUpsideDown)
@property (nonatomic, assign) BOOL autorotate;

/// 视频的帧率，即 fps
@property (nonatomic, assign) NSUInteger videoFrameRate;

/// 视频的最大帧率，即 fps
@property (nonatomic, assign) NSUInteger videoMaxFrameRate;

/// 视频的最小帧率，即 fps
@property (nonatomic, assign) NSUInteger videoMinFrameRate;

/// 最大关键帧间隔，可设定为 fps 的2倍，影响一个 gop 的大小
@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;

/// 视频的码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoBitRate;

/// 视频的最大码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMaxBitRate;

/// 视频的最小码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoMinBitRate;

///< 分辨率
@property (nonatomic, assign) LFLiveVideoSessionPreset sessionPreset;

///< ≈sde3分辨率
@property (nonatomic, assign, readonly) NSString *avSessionPreset;

///< 是否是横屏
@property (nonatomic, assign, readonly) BOOL landscape;

@end
