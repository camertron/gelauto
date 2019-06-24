module Gelauto
  module CLIUtils
    EXTS = (ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']).freeze

    def which(cmd)
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        EXTS.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end

      nil
    end

    extend self
  end
end
