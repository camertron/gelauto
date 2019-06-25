module GelautoSpecs
  class System
    def self.configure(config)
      @config = config
      nil
    end
  end
end

Gelauto.paths << __FILE__
