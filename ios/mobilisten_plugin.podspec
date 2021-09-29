#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mobilisten_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mobilisten_plugin'
  s.version          = '4.2.0'
  s.summary          = 'SalesIQ Mobilisten Flutter Plugin'
  s.description      = <<-DESC
SalesIQ Mobilisten Flutter Plugin
                       DESC
  s.homepage         = 'https://www.zoho.com/salesiq'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rishabh Raghunath' => 'rishabh.r@zohocorp.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.dependency "Mobilisten", "#{s.version}"
  s.swift_version = '5.0'
end
