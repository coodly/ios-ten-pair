use_frameworks!

def local_coodly
    pod 'SWLogger', :path => '../swift-logger'
    pod 'GameKit', :path => '../swift-game-kit'
    pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
    pod 'LaughingAdventure/Feedback', :path => '../swift-laughing-adventure'
end

def remote_coodly
    pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git', :branch => 'macos'
    pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
    pod 'LaughingAdventure/Feedback', :git => 'https://github.com/coodly/laughing-adventure.git'
end

def pods
    pod 'Firebase/Core', '3.2.1'
    pod 'Firebase/AdMob', '3.2.1'
    pod 'Locksmith', '2.0.8'
    
    remote_coodly
    #local_coodly
end

target 'TenPair' do
    platform :ios, '8.0'

    pods
end

target 'TenPairTests' do
    platform :ios, '8.0'

end

def local_coodly_mac
    pod 'SWLogger', :path => '../swift-logger'
    pod 'GameKit', :path => '../swift-game-kit'
    pod 'LaughingAdventure/Purchase', :path => '../swift-laughing-adventure'
end

def remote_coodly_mac
    pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    pod 'GameKit', :git => 'git@github.com:coodly/GameKit.git', :branch => 'macos'
    pod 'LaughingAdventure/Purchase', :git => 'https://github.com/coodly/laughing-adventure.git'
end

def mac_pods
    remote_coodly_mac
    #local_coodly_mac
end

target 'MacTenPair' do
    platform :osx, '10.11'
    
    mac_pods
end
