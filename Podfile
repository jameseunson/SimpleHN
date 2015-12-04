platform :ios, '9.0'
use_frameworks!

link_with 'SimpleHN', 'SimpleHN-objcTests'

pod 'Firebase', '~> 2.4.0'
pod 'Mantle'
pod 'TimeAgoInWords', '~> 2.0.0'
pod 'JBNSLayoutConstraint', '~> 1.0.0'
pod 'RegexKitLite', '~> 4.0'
pod 'hpple', :git => 'https://github.com/topfunky/hpple.git' # YOLO
pod 'AFNetworking', '~> 2.6.3'
pod 'DTCoreText', '~> 1.6.16'
pod 'TTTAttributedLabel'
pod 'InAppSettingsKit'
pod 'DKNightVersion', '~> 0.9.1'
pod 'MCSwipeTableViewCell', '~> 2.1.4'
pod 'FirebaseUI/Core', '~> 0.3'
pod 'Fabric'
pod 'Crashlytics'

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    def installer.verify_no_static_framework_transitive_dependencies; end
end