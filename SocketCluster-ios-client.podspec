#
# Be sure to run `pod lib lint SocketCluster-ios-client.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SocketCluster-ios-client"
  s.version          = "2.1.0"
  s.summary          = "Native iOS client for SocketCluster http://socketcluster.io/"

  s.description      = "Native iOS client for SocketCluster http://socketcluster.io/."

  s.homepage         = "https://github.com/abpopov/SocketCluster-ios-client"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Anatoliy" => "popov.anatoliy@gmail.com" }
  s.source           = { :git => "https://github.com/abpopov/SocketCluster-ios-client.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SocketCluster-ios-client' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'SocketRocket'
end
