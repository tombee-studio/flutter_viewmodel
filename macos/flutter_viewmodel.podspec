Pod::Spec.new do |s|
  s.name             = 'flutter_viewmodel'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter package that introduces the ViewModel pattern for Flutter applications.'
  s.description      = <<-DESC
A Flutter package that introduces the ViewModel pattern for Flutter applications,
inspired by Android's Architecture Components ViewModel.
                       DESC
  s.homepage         = 'https://github.com/your-org/flutter_viewmodel'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Organization' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
