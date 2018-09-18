Pod::Spec.new do |s|
  s.name         = 'SemiModalViewController'
  s.version      = '0.4'
  s.platform 	   = :ios, '8.0'
  s.summary      = 'Present view / view controller as bottom-half modal'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/muyexi/SemiModalViewController'
  s.author       = { 'muyexi' => 'muyexi@gmail.com' }
  s.source       = { :git => 'https://github.com/muyexi/SemiModalViewController.git', :tag => s.version }
  s.source_files = 'Source/*.swift'
end
