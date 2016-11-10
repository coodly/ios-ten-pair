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
        pod 'GameKit', :path => '../swift-game-kit'
    elsif UsedSource == PodSource::Remote
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
        pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git'
    else
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git', :tag => '0.1.2'
        pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git', :tag => '0.2.0'
    end
end

def ios_pods
    pod 'Firebase/Core', '3.2.1'
    pod 'Firebase/AdMob', '3.2.1'
    pod 'Locksmith', '3.0.0'

    shared

    if UsedSource == PodSource::Local
        pod 'LaughingAdventure', :path => '../swift-laughing-adventure'
    elsif UsedSource == PodSource::Remote
        pod 'LaughingAdventure', :git => 'https://github.com/coodly/laughing-adventure.git'
    else
        pod 'LaughingAdventure', :git => 'https://github.com/coodly/laughing-adventure.git', :tag => '0.2.1'
    end
end

target 'TenPair' do
    platform :ios, '9.3'

    ios_pods
end

target 'TenPairTests' do
    platform :ios, '9.3'

end

target 'MacTenPair' do
    platform :osx, '10.11'
    
    shared
    
    if UsedSource == PodSource::Local
        pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
    elsif UsedSource == PodSource::Remote
        pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
    else
        pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git', :tag => '0.2.1'
    end
end
