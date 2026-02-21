require 'xcodeproj'

project_path = 'OpenTalk.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'OpenTalk' }
group = project.main_group.find_subpath('OpenTalk', true)

# create reference
file_ref = group.new_reference('LaunchScreen.storyboard')
target.resources_build_phase.add_file_reference(file_ref)

target.build_configurations.each do |config|
  config.build_settings.delete('INFOPLIST_KEY_UILaunchScreen_Generation')
  config.build_settings.delete('INFOPLIST_KEY_UILaunchScreen_UIColorName')
  config.build_settings.delete('INFOPLIST_KEY_UILaunchScreen_UIImageName')
  config.build_settings['INFOPLIST_KEY_UILaunchStoryboardName'] = 'LaunchScreen'
end

project.save
