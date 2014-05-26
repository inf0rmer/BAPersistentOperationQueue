#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "BAPersistentOperationQueue"
  s.version          = "1.0.1"
  s.summary          = "A persistent operation queue that uses a database to save operations that need to be completed at a later time."
  s.description      = <<-DESC
                       A FIFO queue that uses both a database and an in-memory queue to save operations that, for some reason, must be completed at a later time. The best use case (and the purpose of its existence!) is to allow POST/PUT/DELETE requests in an app to be saved and performed in their correct order at a later time, in case the network connection is unavailable. It uses an NSOperationQueue to automatically handle these operations in separate threads, and makes use of delegate methods to provide the host application “hooks” to serialize and deserialize objects for greater flexibility.
                       DESC
  s.homepage         = "http://inf0rmer.github.io/BAPersistentOperationQueue"
  s.license          = 'MIT'
  s.author           = { "Bruno Abrantes" => "inf0rmer.realm@gmail.com" }
  s.source           = { :git => "https://github.com/inf0rmer/BAPersistentOperationQueue.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/inf0rmer'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'BAPersistentOperationQueue/Classes/**/*'
  s.public_header_files = 'BAPersistentOperationQueue/Classes/**/*.h'

  s.dependency 'FMDB'
end
