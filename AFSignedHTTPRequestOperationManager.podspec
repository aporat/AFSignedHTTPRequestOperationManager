Pod::Spec.new do |s|
  s.name     = 'AFSignedHTTPRequestOperationManager'
  s.version  = '3.0.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'AFNetworkingAutomatically sign AFNetworking api requests with SHA-256 hash signature and timestamp'
  s.homepage = 'https://github.com/aporat/AFSignedHTTPRequestOperationManager'
  s.author   = { 'Adar Porat' => 'http://github.com/aporat' }
  s.source   = { :git => 'https://github.com/aporat/AFSignedHTTPRequestOperationManager.git', :tag => '1.1.0' }
  
  s.platform = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'src/*.{h,m}'
  s.dependency 'IGDigest', '~> 1.1.0'
  s.dependency 'AFNetworking', '~> 3'

end
