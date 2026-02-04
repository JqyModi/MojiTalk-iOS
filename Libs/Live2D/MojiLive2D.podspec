Pod::Spec.new do |s|
  s.name             = 'MojiLive2D'
  s.version          = '0.1.0'
  s.summary          = 'Live2D Cubism SDK for MojiTalk (with MotionSync)'
  s.description      = <<-DESC
                       Local integration of Live2D Cubism SDK, MotionSync and Wrapper.
                       DESC
  s.homepage         = 'https://github.com/example/MojiLive2D'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'Author' => 'author@example.com' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '13.0'
  s.requires_arc = 'Bridge/**/*.{h,m,mm}'

  # Preservation
  s.preserve_paths = 'Core/include/**/*.h', 'Framework/src/**/*', 'MotionSync/Framework/src/**/*'
  
  # Source Files: Framework + Bridge + MotionSync
  # Note: Exclude duplicate readme if any match
  s.source_files = 'Framework/src/**/*.{h,hpp,c,cpp,m,mm}', 'Bridge/**/*.{h,m,mm}', 'MotionSync/Framework/src/**/*.{h,hpp,c,cpp}', 'Core/include/**/*.{h,hpp}', 'MotionSync/Core/include/**/*.{h,hpp}'
  s.exclude_files = '**/*_Win.cpp', '**/*_Win.hpp', '**/*Windows.cpp'
  
  # Core Library & MotionSync Library
  s.vendored_libraries = 'Core/lib/ios/libLive2DCubismCore_fat.a', 'MotionSync/Core/CRI/lib/iOS/libLive2DCubismMotionSyncEngine_CRI_fat.a'

  # Preserve directory structure for headers
  s.header_mappings_dir = '.'
  
  # Headers
  # Expose headers
  s.public_header_files = 'Bridge/L2DCubism.h', 'Bridge/MOJiMTKView.h', 'Bridge/MOJiL2DConfigurationModel.h'
  
  # Headers structure flattening for simplicity or keep dir?
  # CocoaPods usually flattens headers unless header_mappings_dir is set.
  # Flat headers are easier to import usually: #import "CubismMotionSync.hpp"
  # As long as search paths are correct.
  
  # System Frameworks
  s.frameworks = 'Metal', 'MetalKit', 'CoreGraphics', 'QuartzCore', 'AudioToolbox', 'AVFoundation'
  s.libraries = 'c++'
  
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/Core/include" "${PODS_TARGET_SRCROOT}/Framework/src" "${PODS_TARGET_SRCROOT}/Bridge" "${PODS_TARGET_SRCROOT}/MotionSync/Framework/src" "${PODS_TARGET_SRCROOT}/MotionSync/Core/include"',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'ALWAYS_SEARCH_USER_PATHS' => 'YES',
    'USE_HEADERMAP' => 'NO'
  }
  
  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/MojiLive2D/Core/include" "${PODS_ROOT}/MojiLive2D/Framework/src" "${PODS_ROOT}/MojiLive2D/Bridge" "${PODS_ROOT}/MojiLive2D/MotionSync/Framework/src" "${PODS_ROOT}/MojiLive2D/MotionSync/Core/include"',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'ALWAYS_SEARCH_USER_PATHS' => 'YES'
  }
end
