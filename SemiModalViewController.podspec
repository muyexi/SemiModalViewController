Pod::Spec.new do |s|
  s.name         = 'SemiModalViewController'
  s.version      = '0.2'
  s.platform 	   = :ios, '8.0'
  s.summary      = 'Swift Port of KNSemiModalViewController'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/muyexi/SemiModalViewController'
  s.author       = { 'muyexi' => 'muyexi@gmail.com' }
  s.source       = { :git => 'https://github.com/muyexi/SemiModalViewController.git', :tag => s.version }
  s.source_files = 'Source/*.swift'
end
