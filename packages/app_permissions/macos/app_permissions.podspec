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

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'app_permissions_privacy' => ['app_permissions/Sources/app_permissions/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
