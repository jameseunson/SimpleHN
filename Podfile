platform :ios, '9.0'
use_frameworks!

pod 'Firebase', '~> 2.4.0'
pod 'FirebaseUI', '~> 0.2'
pod 'Mantle'
pod 'TimeAgoInWords', '~> 2.0.0'
pod 'KILabel', '~> 1.0.1'

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    def installer.verify_no_static_framework_transitive_dependencies; end
end