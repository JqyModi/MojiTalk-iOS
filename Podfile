platform :ios, '16.0'
use_frameworks!

target 'MojiTalk' do
  # Use local Live2D pod
  pod 'MojiLive2D', :path => './Libs/Live2D'
  pod 'SSZipArchive'
  
  # Add other dependencies if needed in the future
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
