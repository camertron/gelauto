module Gelauto
  class ArgList
    include Enumerable

    attr_reader :args

    def initialize(args = [])
      @args = args
    end

    def <<(arg)
      args << arg
    end

    def [](idx)
      args[idx]
    end

    def empty?
      args.empty?
    end

    def each(&block)
      args.each(&block)
    end

    def to_sig
      return '' if args.empty?
      args.map(&:to_sig).join(', ')
    end
  end
end
