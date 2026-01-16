#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint app_permissions.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'app_permissions'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for checking and requesting permissions.'
  s.description      = <<-DESC
A Flutter plugin for checking and requesting permissions (Accessibility, Input Monitoring, Microphone) on macOS, Windows, iOS, and Android.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'app_permissions/Sources/app_permissions/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'app_permissions_privacy' => ['app_permissions/Sources/app_permissions/PrivacyInfo.xcprivacy']}
end
