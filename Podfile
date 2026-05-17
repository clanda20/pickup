source 'https://cdn.cocoapods.org/'
platform :ios, '15.0'
use_frameworks!

def common_pods
        pod 'FirebaseCore', '12.13.0'
        pod 'FirebaseAuth', '12.13.0'
        pod 'FirebaseDatabase', '12.13.0'
        pod 'FirebaseStorage', '12.13.0'
        pod 'FirebaseMessaging', '12.13.0'
end

target 'pickup' do
    common_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            config.build_settings['SWIFT_VERSION'] = '5.0'
            config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        end
    end
end
