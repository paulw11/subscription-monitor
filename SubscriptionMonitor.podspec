#
# Be sure to run `pod lib lint SubscriptionMonitor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SubscriptionMonitor'
  s.version          = '0.1.0'
  s.summary          = 'A framework for monitoring auto renewing subscriptions on iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SubscriptionManager automates the tasks required to validate in-app purchase receipts for auto-renewing subscriptions.
It will periodically refresh the application receipt and validate it against your server.  It will then deliver an NSNotification (and optionally invoke a closure) to let your app know that the receipt has been refreshed and that it should check for changes in subscriptions.
                       DESC

  s.homepage         = 'https://github.com/paulw11/SubscriptionMonitor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'paulw' => 'paulw@wilko.me' }
  s.source           = { :git => 'https://github.com/paulw11/SubscriptionMonitor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/paulwilko'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SubscriptionMonitor/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SubscriptionMonitor' => ['SubscriptionMonitor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
