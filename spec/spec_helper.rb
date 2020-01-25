$:.push(File.dirname(__FILE__))

require 'rspec'
require 'gelauto'
require 'pry-byebug'

Dir.chdir('spec') do
  Dir.glob('support/*.rb').each do |f|
    require f
  end
end

RSpec.configure do |config|
  config.include(GelautoSpecs::AcceptMatcher)
  config.include(GelautoSpecs::HandBackMatcher)

  config.include(
    Module.new do
      def get_indexed_method(obj, method_name)
        path, lineno = obj.method(method_name).source_location
        Gelauto.method_index.find(path, lineno)
      end

      def annotate(obj, method_name, code)
        path, _lineno = obj.method(method_name).source_location
        Gelauto.method_index.annotate(path, code)
      end
    end
  )
end

# quiet logs for test runs
Gelauto.logger.level = :fatal
