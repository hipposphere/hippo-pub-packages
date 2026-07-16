#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint hid_api_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'hid_api_macos'
  s.version          = '0.1.8'
  s.summary          = 'macOS implementation of the federated hid_api plugin.'
  s.description      = <<-DESC
macOS implementation of the federated hid_api plugin.
                       DESC
  s.homepage         = 'https://hippolabs.org'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hipposphere UG' => 'legal@hipposphere.example' }

  s.source           = { :path => '.' }
  s.source_files = 'hid_api_macos/Sources/hid_api_macos/**/*.swift'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'hid_api_macos_privacy' => ['hid_api_macos/Sources/hid_api_macos/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
