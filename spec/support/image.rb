module GelautoSpecs
  class Image
    def self.path
      __FILE__
    end

    attr_reader :path, :width, :height

    def initialize(path, width, height)
      @path = path
      @width = width
      @height = height
    end

    def aspect_ratio
      width.to_f / height
    end
  end
end

Gelauto.paths << __FILE__
