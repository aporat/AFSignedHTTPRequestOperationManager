Pod::Spec.new do |s|
  s.name         = "AFSignedHTTPRequestOperationManager"
  s.version      = "3.1.1"
  s.license      = { :type => "MIT" }
  s.homepage     = "https://github.com/aporat/AFSignedHTTPRequestOperationManager"
  s.author           = { "Adar Porat" => "adar.porat@gmail.com" }
  s.summary      = "AFNetworkingAutomatically sign AFNetworking api requests with SHA-256 hash signature and timestamp"
  s.source           = { :git => "https://github.com/aporat/AFSignedHTTPRequestOperationManager.git", :tag => s.version.to_s }

  s.ios.deployment_target = "7.0"

  s.source_files = "Source/*.{m,h}"

  s.requires_arc = true

  s.dependency "AFNetworking",  "~> 3"
  s.dependency "IGDigest",  "~> 1.1.0"

end
