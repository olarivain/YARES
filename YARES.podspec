version = '0.0.4'

Pod::Spec.new do |s|
  s.name          = 'YARES'
  s.version       = version

  # support for both ios and osx
  s.platform = :osx, '10.7'
  
  s.author        = { 'kra Larivain' => 'olarivain@gmail.com' }
  s.license       = { :type => 'LPRAB', :text => <<-LICENSE
                LICENCE PUBLIQUE RIEN À BRANLER 
                      Version 1, Mars 2009 

 Copyright (C) 2009 Sam Hocevar 
  14 rue de Plaisance, 75014 Paris, France 
  
 La copie et la distribution de copies exactes de cette licence sont 
 autorisées, et toute modification est permise à condition de changer 
 le nom de la licence.  

         CONDITIONS DE COPIE, DISTRIBUTON ET MODIFICATION 
               DE LA LICENCE PUBLIQUE RIEN À BRANLER 

  0. Faites ce que vous voulez, j’en ai RIEN À BRANLER. 
                 LICENSE
  }
  s.homepage      = 'http://github.com/olarivain/YARES.git'
  s.summary       = 
<<-DESC
Yet another rest server.
DESC
  s.description   = 
<<-DESC
REST server, written mostly for fun.
DESC
  s.source        = { :git => 'https://github.com/olarivain/YARES.git', :tag => "v#{version}" }
  s.requires_arc  = true
  s.source_files  = ["YARES/**/*.{h,m,c,mm,cpp}"]

  s.dependency    'KraCommons', '~> 0.0.1'
  
end