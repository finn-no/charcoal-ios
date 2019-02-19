Pod::Spec.new do |s|
  s.name             = 'Charcoal'
  s.summary          = 'A library that simplifies the creation of modern filtering experiences'
  s.version          = '0.1.0'
  s.author           = 'FINN.no'
  s.homepage         = 'https://github.com/finn-no/charcoal-ios'
  s.social_media_url = 'https://twitter.com/FINN_tech'
  s.source           = { :git => 'https://github.com/finn-no/charcoal-ios.git', :tag => s.version }
  s.description      = <<-DESC
  Charcoal is a declarative library that simplifies the creation of modern filtering experiences. It allows you in a flexible way to represent complex filtering flows in just a few steps. When building Charcoal we have taken major steps to ensure every UI element is refined to provide a great experience to your users, taking in account things such as accessibility and customization.
                       DESC
  s.license          = 'MIT'
  s.platform         = :ios, '9.0'
  s.requires_arc     = true
  s.swift_version    = '4.2'
  s.source_files     = 'Sources/**/*.swift', 'Resources/*.swift'
  s.resources    = 'Resources/*.xcassets', 'Resources/*.lproj'
  s.resource_bundles = {
      'Charcoal' => ['Resources/*.xcassets', 'Resources/*.lproj']
  }
  s.frameworks       = 'Foundation', 'UIKit', 'FinniversKit'
  s.dependency 'FinniversKit'
end
