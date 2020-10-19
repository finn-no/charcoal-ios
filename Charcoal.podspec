Pod::Spec.new do |s|
  s.name             = 'Charcoal'
  s.summary          = 'A library that simplifies the creation of modern filtering experiences'
  s.version          = '9.0.0'
  s.author           = 'FINN.no'
  s.homepage         = 'https://github.com/finn-no/charcoal-ios'
  s.social_media_url = 'https://twitter.com/FINN_tech'
  s.description      = <<-DESC
  Charcoal is a declarative library that simplifies the creation of modern filtering experiences. It allows you in a flexible way to represent complex filtering flows in just a few steps. When building Charcoal we have taken major steps to ensure every UI element is refined to provide a great experience to your users, taking in account things such as accessibility and customization.
                       DESC
  s.license          = 'MIT'
  s.platform         = :ios, '11.2'
  s.requires_arc     = true
  s.swift_version    = '5.0'

  s.source           = { :git => 'https://github.com/finn-no/charcoal-ios.git', :tag => s.version }
  s.default_subspec = "Core"
  s.cocoapods_version = '>= 1.4.0'

  s.subspec "Core" do |ss|
    ss.source_files  = 'Sources/Charcoal/**/*.swift'
    ss.resources    = 'Sources/Charcoal/Resources/*.{xcassets,lproj}'
    ss.resource_bundles = {
        'Charcoal' => ['Sources/Charcoal/Resources/*.xcassets', 'Sources/Charcoal/Resources/*.lproj']
    }
    ss.dependency 'FinniversKit'
    ss.frameworks = 'Foundation', 'UIKit', 'FinniversKit'
  end

  s.subspec "FINN" do |ss|
    ss.source_files = 'Sources/FINNSetup/**/*.swift'
    ss.dependency "Charcoal/Core"
  end
end
