#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint video_stream.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'video_stream'
  s.version          = '0.0.1'
  s.summary          = 'A rtmp plugin'
  s.description      = <<-DESC
A rtmp plugin
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'


  s.subspec 'LFLiveKit' do |ss|
       ss.name         = "LFLiveKit"
       ss.source_files  = "LFLiveKit/**/*.{h,m,mm,cpp,c}"
       ss.public_header_files = ['LFLiveKit/*.h', 'LFLiveKit/objects/*.h', 'LFLiveKit/configuration/*.h']
       ss.frameworks = "VideoToolbox", "AudioToolbox","AVFoundation","Foundation","UIKit"
       ss.libraries = "c++", "z"
       ss.requires_arc = true
  end

  s.dependency 'MJExtension'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
