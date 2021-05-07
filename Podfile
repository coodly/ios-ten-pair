source 'https://github.com/coodly/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

module PodSource
    Local = 1
    Remote = 2
    Tagged = 3
end

UsedSource = PodSource::Remote

def feedback_pod
    if UsedSource == PodSource::Local
        pod 'CloudFeedback/Client', :path => '../swift-cloud-feedback'
        pod 'CloudFeedback/iOS', :path => '../swift-cloud-feedback'
    elsif UsedSource == PodSource::Remote
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git'
    else
        pod 'CloudFeedback/Client', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.3.3'
        pod 'CloudFeedback/iOS', :git => 'git@github.com:coodly/CloudFeedback.git', tag: '0.3.3'
    end
end

def insight_pod
  if UsedSource == PodSource::Local
    pod 'CloudInsight', :path => '../swift-cloud-insight'
  elsif UsedSource == PodSource::Remote
    pod 'CloudInsight', :git => 'git@github.com:coodly/CloudInsight.git'
  else
    pod 'CloudInsight', :git => 'git@github.com:coodly/CloudInsight.git', :tag => '0.1.7'
  end
end

target 'iOS' do
    platform :ios, '13.0'

    feedback_pod
    insight_pod
end

target 'Catalyst' do
    platform :ios, '13.0'

    #insight_pod
end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
end
