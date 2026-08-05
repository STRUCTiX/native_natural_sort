#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_natural_sort.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_natural_sort'
  s.version          = '0.1.1'
  s.summary          = 'Locale-aware, numeric-aware natural string sorting for Flutter using each platform\'s native collation engine.'
  s.description      = <<-DESC
Locale-aware, numeric-aware natural string sorting for Flutter using each platform's native collation engine.
                       DESC
  s.homepage         = 'https://github.com/FriesI23/native_natural_sort'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fries_I23' => 'https://github.com/FriesI23' }

  s.source           = { :path => '.' }
  s.source_files = 'native_natural_sort/Sources/native_natural_sort/**/*.swift'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'native_natural_sort_privacy' => ['native_natural_sort/Sources/native_natural_sort/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
