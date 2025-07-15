Pod::Spec.new do |s|
  s.name = 'VastClient3'
  s.authors = { 'Craig Holliday' => 'craig.holliday@realeyes.com'}
  s.version = '4.2.0'
  s.license = 'MIT'
  s.summary = 'Vast Client is a Swift Framework which implements the VAST 4.2 spec'
  s.homepage = 'https://github.com/carlosDigio/ios-vast-client'
  s.source = { :git => 'https://github.com/carlosDigio/ios-vast-client.git', :tag => s.version }
  s.tvos.deployment_target = '14.0'
  s.ios.deployment_target = '14.0'
  s.source_files = 'Sources/VastClient/**/*.swift'
end
