source 'https://github.com/coodly/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

module PodSource
    Local = 1
    Remote = 2
    Tagged = 3
end

UsedSource = PodSource::Remote

def logger
    if UsedSource == PodSource::Local
        pod 'SWLogger', :path => '../swift-logger'
    elsif UsedSource == PodSource::Remote
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git'
    else
        pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git', :tag => '0.4.3'
    end
end

def ios_pods
    pod 'Google-Mobile-Ads-SDK', '7.61.0'
    pod 'Firebase/Crashlytics', '6.27.0'

    logger
end

def feedback_pod
    if UsedSource == PodSource::Local
        pod 'CloudFeedback/Client', :path => '../swift-cloud-feedback'
        pod 'CloudFeedback/iOS', :path => '../swift-cloud-feedback'
    elsif UsedSource == PodSource::Remote
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git'
    else
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.2.11'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.2.11'
    end
end

def insight_pod
  if UsedSource == PodSource::Local
    pod 'CloudInsight', :path => '../swift-cloud-insight'
  elsif UsedSource == PodSource::Remote
    pod 'CloudInsight', :git => 'git@github.com:coodly/CloudInsight.git'
  else
    pod 'CloudInsight', :git => 'git@github.com:coodly/CloudInsight.git', :tag => '0.1.5'
  end
end

target 'iOS' do
    platform :ios, '11.4'

    ios_pods
    feedback_pod
    insight_pod
    pod 'PersonalizedAdConsent', '1.0.5'
end

target 'Catalyst' do
    platform :ios, '11.4'

    insight_pod
    logger
end
