platform :ios, '8.0'

use_frameworks!


def local_coodly
    pod 'SWLogger', :path => '../swift-logger'
    pod 'GameKit', :path => '../swift-game-kit'
end

def remote_coodly
    pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git'
end

def pods
    pod 'Fabric'
    pod 'Crashlytics'

    remote_coodly
end

target 'TenPair' do
    pods
end

target 'TenPairTests' do
    pods
end