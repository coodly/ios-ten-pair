source 'https://github.com/coodly/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

module PodSource
    Local = 1
    Remote = 2
    Tagged = 3
end

UsedSource = PodSource::Remote

def shared
    if UsedSource == PodSource::Local
        pod 'SWLogger', :path => '../swift-logger'
    elsif UsedSource == PodSource::Remote
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    else
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git', :tag => '0.3.1'
    end
end

def ios_pods
    pod 'Google-Mobile-Ads-SDK', '7.60.0'
    pod 'Locksmith', '4.0.0'
    pod 'Firebase/Crashlytics', '6.25.0'

    shared

    if UsedSource == PodSource::Local
        pod 'SpriteKitUI/iOS', :path => '../swift-sprite-kit-ui'
    elsif UsedSource == PodSource::Remote
        pod 'SpriteKitUI/iOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :branch => 'master'
    else
        pod 'SpriteKitUI/iOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :tag => '0.4.0'
    end
end

def feedback_pod
    if UsedSource == PodSource::Local
        pod 'CloudFeedback/Client', :path => '../swift-cloud-feedback'
        pod 'CloudFeedback/iOS', :path => '../swift-cloud-feedback'
    elsif UsedSource == PodSource::Remote
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git'
    else
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.2.5'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.2.5'
    end
end

target 'iOS' do
    platform :ios, '10.3'

    ios_pods
    feedback_pod
end

target 'macOS' do
    platform :osx, '10.11'
    
    shared
    
    if UsedSource == PodSource::Local
        pod 'SpriteKitUI/macOS', :path => '../swift-sprite-kit-ui'
    elsif UsedSource == PodSource::Remote
        pod 'SpriteKitUI/macOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :branch => 'master'
    else
        pod 'SpriteKitUI/macOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :tag => '0.4.0'
    end
end
