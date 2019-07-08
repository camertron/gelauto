require 'logger'

module Gelauto
  class NullLogger < ::Logger
    def initialize(*)
      super(File.open(File::NULL, 'w'))
    end

    def debug(*); end
    def info(*); end
    def warn(*); end
    def error(*); end
    def fatal(*); end
  end
end
