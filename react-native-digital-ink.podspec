require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-digital-ink"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/railsjack/react-native-digital-ink.git", :tag => "#{s.version}" }

  
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  

  s.dependency "React"
  s.dependency "GoogleMLKit" , "~> 4.0.0"
  s.dependency "GoogleMLKit/DigitalInkRecognition" , "~> 4.0.0"
  s.framework = "MLKit"
end
