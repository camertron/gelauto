require 'logger'
require 'parser/current'

module Gelauto
  autoload :ArgList,     'gelauto/arg_list'
  autoload :ArrayType,   'gelauto/array_type'
  autoload :BooleanType, 'gelauto/boolean_type'
  autoload :CLIUtils,    'gelauto/cli_utils'
  autoload :GenericType, 'gelauto/generic_type'
  autoload :HashType,    'gelauto/hash_type'
  autoload :Logger,      'gelauto/logger'
  autoload :MethodDef,   'gelauto/method_def'
  autoload :MethodIndex, 'gelauto/method_index'
  autoload :Namespace,   'gelauto/namespace'
  autoload :NullLogger,  'gelauto/null_logger'
  autoload :Rbi,         'gelauto/rbi'
  autoload :Type,        'gelauto/type'
  autoload :TypeSet,     'gelauto/type_set'
  autoload :Utils,       'gelauto/utils'
  autoload :Var,         'gelauto/var'

  class << self
    attr_accessor :paths
    attr_writer :logger

    def setup
      enable_traces
      index_methods
    end

    def teardown
      disable_traces
    end

    def discover
      setup
      yield
    ensure
      teardown
    end

    def method_index
      @method_index ||= MethodIndex.new
    end

    def paths
      @paths ||= []
    end

    def each_absolute_path(&block)
      Utils.each_absolute_path(paths, &block)
    end

    def register_type(type, handler)
      types[type] = handler
    end

    def types
      @types ||= Hash.new(Gelauto::Type)
    end

    def introspect(obj)
      Gelauto.types[obj.class].introspect(obj)
    end

    def annotate_file(path)
      annotated_code = Gelauto.method_index.annotate(path, File.read(path))
      File.write(path, annotated_code)
    end

    def logger
      @logger ||= ::Logger.new(STDERR)
    end

    private

    def enable_traces
      call_trace.enable
      return_trace.enable
    end

    def disable_traces
      call_trace.disable
      return_trace.disable
    end

    def index_methods
      each_absolute_path.with_index do |path, idx|
        begin
          method_index.index_methods_in(
            path, Parser::CurrentRuby.parse(File.read(path))
          )

          Gelauto::Logger.info("Indexed #{idx + 1}/#{paths.size} paths")
        rescue Parser::SyntaxError => e
          Gelauto::Logger.error("Syntax error in #{path}, skipping")
        end
      end
    end

    def call_trace
      @call_trace ||= TracePoint.new(:call) do |tp|
        if md = method_index.find(tp.path, tp.lineno)
          md.args.each do |arg|
            var = tp.binding.local_variable_get(arg.name)
            arg.types << Gelauto.introspect(var)
          end
        end
      end
    end

    def return_trace
      @return_trace ||= TracePoint.new(:return) do |tp|
        if md = method_index.find(tp.path, tp.lineno)
          md.return_types << Gelauto.introspect(tp.return_value)
        end
      end
    end
  end
end

Gelauto.register_type(::Hash, Gelauto::HashType)
Gelauto.register_type(::Array, Gelauto::ArrayType)
Gelauto.register_type(::TrueClass, Gelauto::BooleanType)
Gelauto.register_type(::FalseClass, Gelauto::BooleanType)
