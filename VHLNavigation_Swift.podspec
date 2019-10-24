
Pod::Spec.new do |s|

  s.name         = "VHLNavigation_Swift"
  s.version      = "1.0"
  s.summary      = "navigationbar color / Dynamic blur / background image/ alpha / hidden"
  s.homepage     = "https://github.com/huanglins/VHLNavigation_Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "vincent" => "gvincent@163.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/huanglins/VHLNavigation_Swift.git", :tag => s.version }
  s.source_files = "VHLNavigation/*.{h,m,swift}"
  s.requires_arc = true
  s.social_media_url = "https://github.com/huanglins"

end