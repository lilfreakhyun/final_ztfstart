#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint learning_digital_ink_recognition.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'learning_digital_ink_recognition'
  s.version          = '0.0.1'
  s.summary          = 'Learning Digital Ink Recognition.'
  s.description      = <<-DESC
  The easy way to use ML Kit for digital ink recognition in Flutter.
                       DESC
  s.homepage         = 'https://github.com/salkuadrat/learning/tree/master/packages/learning_digital_ink_recognition'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Salman S' => 'salkuadrat@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/DigitalInkRecognition'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
