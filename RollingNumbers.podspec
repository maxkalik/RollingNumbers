#
#  Be sure to run `pod spec lint RollingNumbers.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = 'RollingNumbers'
  s.version          = '0.1.2'
  s.summary          = 'RollingNumbers is a lightweight UIView for getting smooth rolling animation between numbers implemented using only CALayer.'
  s.homepage         = 'https://github.com/maxkalik/RollingNumbers'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Max Kalik' => 'maxkalik@gmail.com' }
  s.source           = { :git => 'https://github.com/maxkalik/RollingNumbers.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/RollingNumbers/**/*'
end
