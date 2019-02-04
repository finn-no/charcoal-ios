# coding: utf-8
if ENV['CI'].to_s == 'true'
  install! 'cocoapods', :deterministic_uuids => false
else
  install! 'cocoapods', :deterministic_uuids => false, :disable_input_output_paths => true
end

source 'https://github.com/CocoaPods/Specs'

platform :ios, '9.0'
# Use dynamic frameworks, so we can use Swift pods.
# Sadly this is all or nothing.
use_frameworks!

# Squash warnings from pods
inhibit_all_warnings!

# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

abstract_target "SharedDependencies" do
  target 'Charcoal' do
    pod 'FinniversKit', :git => 'https://github.com/finn-no/FinniversKit.git', :branch => 'master'
    pod 'HockeySDK', '~> 5.0'

    target 'Demo' do
      inherit! :search_paths
    end
  end
end

# Dependency of dependency, make sure to set Swift Language Version to 4.*
swift4_2_pods = ['FinniversKit']

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if swift4_2_pods.include?(target.name)
        config.build_settings['SWIFT_VERSION'] = '4.2'
      else
        config.build_settings['SWIFT_VERSION'] = '3.2'
      end
    end
  end
end