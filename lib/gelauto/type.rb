module Gelauto
  class Type
    def self.introspect(obj)
      new(obj.class)
    end

    attr_reader :ruby_type

    def initialize(ruby_type)
      @ruby_type = ruby_type
    end

    def to_sig
      # i.e. class name
      ruby_type.name
    end
  end
end
