require 'set'

module Gelauto
  class TypeSet
    include Enumerable

    attr_reader :set

    def initialize
      @set = {}
    end

    def size
      set.size
    end

    def empty?
      set.empty?
    end

    def <<(type)
      set[type.ruby_type] = type
    end

    def merge!(other)
      other.set.each do |other_ruby_type, other_type|
        if set[other_ruby_type]
          set[other_ruby_type].merge!(other_type)
        else
          set[other_ruby_type] = other_type
        end
      end
    end

    def each(&block)
      set.each_value(&block)
    end

    def to_sig
      nilable = false

      sigs = set.each_with_object([]) do |(rt, t), ret|
        if rt == ::NilClass
          nilable = true
        else
          ret << t.to_sig
        end
      end

      sigs.uniq!

      if sigs.size == 0
        'T.untyped'
      elsif sigs.size == 1
        sigs.first
      elsif nilable
        "T.nilable(T.any(#{sigs.join(', ')}))"
      else
        "T.any(#{sigs.join(', ')})"
      end
    end
  end
end
