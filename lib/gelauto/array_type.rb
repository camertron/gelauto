module Gelauto
  class ArrayType < GenericType
    def self.introspect(obj)
      new.tap do |var|
        obj.each { |elem| var[:elem] << Gelauto.introspect(elem) }
      end
    end

    def initialize
      super(::Array, [:elem])
    end

    def to_sig
      if self[:elem].empty?
        'T::Array[T.untyped]'
      else
        "T::Array[#{self[:elem].to_sig}]"
      end
    end

    def merge!(other)
      self[:elem].merge!(other[:elem])
    end
  end
end
