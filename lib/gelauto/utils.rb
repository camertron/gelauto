module Gelauto
  module Utils
    def each_absolute_path(paths)
      return to_enum(__method__, paths) unless block_given?

      paths.each do |path|
        yield File.expand_path(path)
      end
    end

    extend self
  end
end
