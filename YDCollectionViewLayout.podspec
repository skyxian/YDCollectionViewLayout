#
# Be sure to run `pod lib lint YDCollectionViewLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YDCollectionViewLayout'
  s.version          = '0.1.0'
  s.summary          = 'collectionView布局类'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
collectionView布局类
                       DESC

  s.homepage         = 'https://github.com/skyxian/YDCollectionViewLayout'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'skyxian' => 'https://github.com/skyxian' }
  s.source           = { :git => 'https://github.com/skyxian/YDCollectionViewLayout.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.1'
  s.source_files = 'YDCollectionViewLayout/Classes/**/*.{swift,h}'
  
  # s.public_header_files = 'YDTCUIKit/Classes/*.{h}'
  
  
  # s.resource_bundles = {
  #   'YDCollectionViewLayout' => ['YDCollectionViewLayout/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
