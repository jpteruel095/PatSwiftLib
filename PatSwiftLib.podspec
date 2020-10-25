#
# Be sure to run `pod lib lint PatSwiftLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PatSwiftLib'
  s.version          = '0.1.1'
  s.summary          = 'A set of helpers for API and other UI functionalities to shorten development time.'
  s.swift_versions   = '5.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  PatSwiftLib is a collection of API that can easily be used to create projects that uses Alamofire, HUDs, and contains several helpers and class extensions for different uses.
                       DESC

  s.homepage         = 'https://github.com/jpteruel095/PatSwiftLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pat-kun' => 'jpteruel95@gmail.com' }
  s.source           = { :git => 'https://github.com/jpteruel095/PatSwiftLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'PatSwiftLib' => ['PatSwiftLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Alamofire', '~> 5.2'
   s.dependency 'SwiftyJSON', '~> 4.0'
end
