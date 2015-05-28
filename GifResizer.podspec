Pod::Spec.new do |s|
  s.name             = "GifResizer"
  s.version          = "1.0.0"
  s.summary          = "An easy way to resize a gif."
  s.homepage         = "https://github.com/gbarcena/GifResizer"
  s.license          = 'MIT'
  s.author           = { "Gustavo" => "gustavo@barcena.me" }
  s.source           = { :git => "https://github.com/gbarcena/GifResizer.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'GifResizer/Source/*'

  s.frameworks = 'UIKit', 'MobileCoreServices', 'ImageIO'
end
