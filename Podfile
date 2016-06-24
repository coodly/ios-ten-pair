use_frameworks!

UseLocalPods = false

def shared
    if UseLocalPods
        pod 'SWLogger', :path => '../swift-logger'
        pod 'GameKit', :path => '../swift-game-kit'
        pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
    else
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
        pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git'
        pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
    end
end

def ios_pods
    pod 'Firebase/Core', '3.2.1'
    pod 'Firebase/AdMob', '3.2.1'
    pod 'Locksmith', '2.0.8'

    shared

    if UseLocalPods
        pod 'LaughingAdventure/Feedback', :path => '../swift-laughing-adventure'
    else
        pod 'LaughingAdventure/Feedback', :git => 'https://github.com/coodly/laughing-adventure.git'
    end
end

target 'TenPair' do
    platform :ios, '8.0'

    ios_pods
end

target 'TenPairTests' do
    platform :ios, '8.0'

end

target 'MacTenPair' do
    platform :osx, '10.11'
    
    shared
end
