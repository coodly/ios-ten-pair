platform :ios, '8.0'

use_frameworks!


def local_coodly
    pod 'SWLogger', :path => '../swift-logger'
    pod 'GameKit', :path => '../swift-game-kit'
    pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
end

def remote_coodly
    pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git'
    pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
end

def pods
    pod 'Fabric', '1.6.7'
    pod 'Crashlytics', '3.7.1'
    pod 'Firebase/Core', '3.2.1'
    pod 'Firebase/AdMob', '3.2.1'

    remote_coodly
    #local_coodly
end

target 'TenPair' do
    pods
end

target 'TenPairTests' do

end
