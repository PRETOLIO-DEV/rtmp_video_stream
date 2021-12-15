//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<camera_with_rtmp/RtmppublisherPlugin.h>)
#import <camera_with_rtmp/RtmppublisherPlugin.h>
#else
@import camera_with_rtmp;
#endif

#if __has_include(<fijkplayer/FijkPlugin.h>)
#import <fijkplayer/FijkPlugin.h>
#else
@import fijkplayer;
#endif

#if __has_include(<flutter_live/FlutterLivePlugin.h>)
#import <flutter_live/FlutterLivePlugin.h>
#else
@import flutter_live;
#endif

#if __has_include(<flutter_webrtc/FlutterWebRTCPlugin.h>)
#import <flutter_webrtc/FlutterWebRTCPlugin.h>
#else
@import flutter_webrtc;
#endif

#if __has_include(<package_info/FLTPackageInfoPlugin.h>)
#import <package_info/FLTPackageInfoPlugin.h>
#else
@import package_info;
#endif

#if __has_include(<path_provider/FLTPathProviderPlugin.h>)
#import <path_provider/FLTPathProviderPlugin.h>
#else
@import path_provider;
#endif

#if __has_include(<video_player/FLTVideoPlayerPlugin.h>)
#import <video_player/FLTVideoPlayerPlugin.h>
#else
@import video_player;
#endif

#if __has_include(<video_stream/VideoStreamPlugin.h>)
#import <video_stream/VideoStreamPlugin.h>
#else
@import video_stream;
#endif

#if __has_include(<wakelock/WakelockPlugin.h>)
#import <wakelock/WakelockPlugin.h>
#else
@import wakelock;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [RtmppublisherPlugin registerWithRegistrar:[registry registrarForPlugin:@"RtmppublisherPlugin"]];
  [FijkPlugin registerWithRegistrar:[registry registrarForPlugin:@"FijkPlugin"]];
  [FlutterLivePlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterLivePlugin"]];
  [FlutterWebRTCPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterWebRTCPlugin"]];
  [FLTPackageInfoPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPackageInfoPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [FLTVideoPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTVideoPlayerPlugin"]];
  [VideoStreamPlugin registerWithRegistrar:[registry registrarForPlugin:@"VideoStreamPlugin"]];
  [WakelockPlugin registerWithRegistrar:[registry registrarForPlugin:@"WakelockPlugin"]];
}

@end
