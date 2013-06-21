require File.expand_path("../lib/nos-record/version", __FILE__)
require "rubygems"
::Gem::Specification.new do |s|
  s.name                      = 'nos-record'
  s.version                   = NosRecord::VERSION
  s.platform                  = ::Gem::Platform::RUBY
  s.authors                   = ['Caleb Crane']
  s.email                     = ['no-reord@simulacre.org']
  s.homepage                  = 'http://github.com/simulacre/nos-record'
  s.summary                   = ''
  s.description               = ''
  s.required_rubygems_version = ">= 1.3.6"
  s.files                     = Dir["lib/**/*.rb", "bin/*", "*.md"]
  s.require_paths             = ['lib']
  s.executables               = Dir["bin/*"].map{|f| f.split('/')[-1] }
  s.license                   = 'MIT'

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
  s.add_dependency 'leveldb-ruby'
  s.add_dependency 'sqlite3'
  s.add_dependency 'redis'
  s.add_dependency 'kyotocabinet-ruby'
  s.add_dependency 'oj'
end
