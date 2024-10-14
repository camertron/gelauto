require 'gelauto'

Gelauto.paths += ENV.fetch('GELAUTO_FILES', '').split(/[\s\n,]/).map(&:strip)
Gelauto.setup

Minitest.after_run do
  Gelauto.teardown

  if ENV['GELAUTO_ANNOTATE'] == 'true'
    Gelauto.each_absolute_path do |path|
      Gelauto.annotate_file(path)
      Gelauto::Logger.info("Annotated #{path}")
    end
  end

  if ENV['GELAUTO_RBI']
    rbi_str = Gelauto::Rbi.new(Gelauto.method_index).to_s

    if ENV['GELAUTO_RBI'] == '-'
      puts rbi_str
    else
      File.write(ENV['GELAUTO_RBI'], rbi_str)
    end
  end
end
