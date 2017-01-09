Pod::Spec.new do |s|
  s.name         = "AFSignedHTTPRequestOperationManager"
  s.version      = "4.1.0"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = "https://github.com/aporat/AFSignedHTTPRequestOperationManager"
  s.author           = { "Adar Porat" => "adar.porat@gmail.com" }
  s.summary      = "Automatically sign AFNetworking api requests with SHA-256 hash signature and timestamp"
  s.source           = { :git => "https://github.com/aporat/AFSignedHTTPRequestOperationManager.git", :tag => s.version.to_s }

  s.ios.deployment_target = "8.0"

  s.source_files = "Source"

  s.requires_arc = true

  s.dependency "AFNetworking/NSURLSession",  "~> 3"
  s.dependency "IGDigest",  "~> 1.1.0"

end
