#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint salesiq_mobilisten.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'salesiq_mobilisten_calls'
  s.version          = '1.0.1'
  s.summary          = 'A new Flutter plugin for SalesIQ Mobilisten Calls'
  s.description      = <<-DESC
SalesIQ Mobilisten Calls Flutter Plugin
                       DESC
  s.homepage         = 'http://mobilisten.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rishabh Raghunath' => 'support@zohosalesiq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.dependency "MobilistenCalls", "#{s.version}"
  s.dependency "Mobilisten", "10.1.4"
  s.swift_version = '5.0'
end
