# -*- encoding: utf-8 -*-
require File.expand_path('../lib/instapaper_download/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sebastian Geiger"]
  gem.email         = ["sebastian.geiger@gmail.com"]
  gem.summary       = %q{instapaper_download provies a binary that lets you download an epub from instapaper and put it on an ebook reader}
  gem.homepage      = "http://sebastiangeiger.github.com/categories/instapaper-download/"
  gem.has_rdoc      = false

  gem.files         = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  gem.executables   = ["instapaper_download"]
  gem.test_files    = []
  gem.name          = "instapaper_download"
  gem.require_path  = "lib"
  gem.add_runtime_dependency 'mechanize', '>= 2.5.0'
  gem.version       = InstapaperDownload::VERSION
end
