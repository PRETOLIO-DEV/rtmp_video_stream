//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

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
  [FLTVideoPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTVideoPlayerPlugin"]];
  [VideoStreamPlugin registerWithRegistrar:[registry registrarForPlugin:@"VideoStreamPlugin"]];
  [WakelockPlugin registerWithRegistrar:[registry registrarForPlugin:@"WakelockPlugin"]];
}

@end
