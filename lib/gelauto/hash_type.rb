module Gelauto
  class HashType < GenericType
    def self.introspect(obj)
      new.tap do |var|
        obj.each_pair do |key, value|
          var[:key] << Gelauto.introspect(key)
          var[:value] << Gelauto.introspect(value)
        end
      end
    end

    def initialize
      super(::Hash, [:key, :value])
    end

    def to_sig
      if self[:key].empty? && self[:value].empty?
        'T::Hash[T.untyped, T.untyped]'
      else
        "T::Hash[#{self[:key].to_sig}, #{self[:value].to_sig}]"
      end
    end

    def merge!(other)
      self[:key].merge!(other[:key])
      self[:value].merge!(other[:value])
    end
  end
end
