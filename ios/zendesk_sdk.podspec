#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zendesk_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name = 'zendesk_sdk'
  s.version = '0.0.1'
  s.summary = 'A Flutter plugin for Zendesk SDK'
  s.description = 'Flutter plugin for integrating Zendesk SDK'
  s.homepage = 'http://example.com'
  s.license = { :file => '../LICENSE' }
  s.author = { 'Vishal Sharma' => 'vishalsharma7nov@gmail.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ZendeskCoreSDK'
  s.dependency 'ZendeskChatSDK'
  s.dependency 'ZendeskSupportSDK'
  s.dependency 'ZendeskAnswerBotSDK'
  s.platform = :ios, '12.0'
  s.ios.deployment_target = '12.0'

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' 
  }
  
  s.swift_version = '5.0'
end
