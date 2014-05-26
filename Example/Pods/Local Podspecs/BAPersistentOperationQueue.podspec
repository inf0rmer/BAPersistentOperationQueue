#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "BAPersistentOperationQueue"
  s.version          = "0.1.0"
  s.summary          = "A short description of BAPersistentOperationQueue."
  s.description      = <<-DESC
                       An optional longer description of BAPersistentOperationQueue

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://EXAMPLE/NAME"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Bruno Abrantes" => "inf0rmer.realm@gmail.com" }
  s.source           = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/EXAMPLE'

  # s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'BAPersistentOperationQueue/Classes/**/*'

  s.ios.exclude_files = 'BAPersistentOperationQueue/Classes/osx'
  s.osx.exclude_files = 'BAPersistentOperationQueue/Classes/ios'
  s.public_header_files = 'BAPersistentOperationQueue/Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  s.dependency 'ObjectiveSugar'
  s.dependency 'FMDB'
  s.dependency 'KVOController'
end
