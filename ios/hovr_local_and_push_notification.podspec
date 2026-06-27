#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'hovr_local_and_push_notification'
  s.version          = '0.1.0'
  s.summary          = 'Local and push notifications for HOVR rider apps.'
  s.description      = <<-DESC
Local and push (FCM) notifications for HOVR rider apps.
                       DESC
  s.homepage         = 'https://github.com/vishalsharma-hovr/hovr_local_and_push_notification'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'HOVR' => 'dev@ridehovr.com' }
  s.source           = { :path => '.' }
  s.source_files = 'hovr_local_and_push_notification/Sources/hovr_local_and_push_notification/**/*'
  s.dependency 'Flutter'
  s.dependency 'FirebaseCore'
  s.dependency 'FirebaseMessaging'
  s.platform = :ios, '16.0'
  s.swift_version = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
