#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint salesiq_mobilisten.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'salesiq_mobilisten'
  s.version          = '6.0.0'
  s.summary          = 'A new Flutter plugin for SalesIQ Mobilisten'
  s.description      = <<-DESC
SalesIQ Mobilisten Flutter Plugin
                       DESC
  s.homepage         = 'http://mobilisten.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rishabh Raghunath' => 'support@zohosalesiq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.dependency "Mobilisten", "#{s.version}"
  s.swift_version = '5.0'
end
