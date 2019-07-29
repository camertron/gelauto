require 'gelauto'

RSpec.configure do |config|
  config.before(:suite) do
    Gelauto.paths += ENV.fetch('GELAUTO_FILES', '').split(/[\s\n,]/).map(&:strip)
    Gelauto.setup
  end

  config.after(:suite) do
    Gelauto.teardown

    if ENV['GELAUTO_ANNOTATE'] == 'true'
      Gelauto.each_absolute_path do |path|
        Gelauto.annotate_file(path)
        Gelauto::Logger.info("Annotated #{path}")
      end
    end
  end
end
