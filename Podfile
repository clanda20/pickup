source 'https://cdn.cocoapods.org/'
platform :ios, '12.0'
use_frameworks!

#Uncomment this line if you're using Swift

def common_pods
        pod 'Firebase'
        pod 'Firebase/Auth'
        pod 'Firebase/Database'
        pod 'Firebase/Storage'
        pod 'FirebaseUI'
        pod 'Firebase/Core'
        pod 'Firebase/Messaging'
        pod 'FBSDKLoginKit'

end

target 'pickup' do
    platform :ios, '12.0'
    common_pods
end

    
    
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
                config.build_settings['SWIFT_VERSION'] = '5.0'
                config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'

            end
        end
    end

