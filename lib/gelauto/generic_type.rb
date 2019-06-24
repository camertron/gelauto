require 'set'

module Gelauto
  class GenericType
    attr_reader :ruby_type, :generic_args

    def initialize(ruby_type, generic_arg_names = [])
      @ruby_type = ruby_type
      @generic_args = {}

      generic_arg_names.each_with_object({}) do |generic_arg_name, ret|
        generic_args[generic_arg_name] = TypeSet.new
      end
    end

    def [](generic_arg_name)
      generic_args[generic_arg_name]
    end

    def to_sig
      raise NotImplementedError, "please define #{__method__} in derived classes"
    end
  end
end
