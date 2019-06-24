require 'set'

module Gelauto
  class MethodDef
    attr_reader :name, :args, :return_types

    def initialize(name, args, return_types = TypeSet.new)
      @name = name
      @args = ArgList.new(args.map { |arg| Var.new(arg) })
      @return_types = return_types
    end

    def to_sig
      components = []

      unless args.empty?
        components << "params(#{args.to_sig})"
      end

      if name == :initialize
        components << 'void'
      else
        components << "returns(#{return_types.to_sig})"
      end

      "sig { #{components.join('.')} }"
    end
  end
end
