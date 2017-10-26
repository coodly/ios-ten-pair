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
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git', :tag => '0.1.2'
    end
end

def ios_pods
    #pod 'Firebase/Core', '4.3.0'
    pod 'Firebase/AdMob', '4.3.0'
    pod 'Locksmith', '4.0.0'

    shared

    if UsedSource == PodSource::Local
        pod 'LaughingAdventure', :path => '../swift-laughing-adventure'
        pod 'SpriteKitUI/iOS', :path => '../swift-sprite-kit-ui'
    elsif UsedSource == PodSource::Remote
        pod 'LaughingAdventure', :git => 'https://github.com/coodly/laughing-adventure.git'
        pod 'SpriteKitUI/iOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :branch => 'master'
    else
        pod 'LaughingAdventure', :git => 'https://github.com/coodly/laughing-adventure.git', :tag => '0.2.1'
        pod 'SpriteKitUI/iOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :tag => '0.2.0'
    end
end

target 'iOS' do
    platform :ios, '9.3'

    ios_pods
end

target 'macOS' do
    platform :osx, '10.11'
    
    shared
    
    if UsedSource == PodSource::Local
        pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
        pod 'SpriteKitUI/macOS', :path => '../swift-sprite-kit-ui'
    elsif UsedSource == PodSource::Remote
        pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
        pod 'SpriteKitUI/macOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :branch => 'master'
    else
        pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git', :tag => '0.2.1'
        pod 'SpriteKitUI/macOS', :git => 'git@github.com:coodly/SpriteKitUI.git', :tag => '0.2.0'
    end
end
