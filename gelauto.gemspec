$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'gelauto/version'

Gem::Specification.new do |s|
  s.name     = 'gelauto'
  s.version  = ::Gelauto::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron/gelauto'

  s.description = s.summary = 'Automatically annotate your code with Sorbet type definitions.'
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'parser', '~> 3.0'
  s.add_dependency 'gli', '~> 2.0'

  s.executables << 'gelauto'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'README.md', 'Rakefile', 'gelauto.gemspec']
end
