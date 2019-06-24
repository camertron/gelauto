require 'gelauto'

RSpec.configure do |config|
  config.before(:suite) { Gelauto.setup }
  config.after(:suite) do
    Gelauto.teardown

    Gelauto.each_absolute_path do |path|
      Gelauto.annotate_file(path)
      Gelauto::Logger.info("Annotated #{path}")
    end
  end
end
