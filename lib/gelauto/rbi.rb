module Gelauto
  class Rbi
    attr_reader :method_index, :paths

    def initialize(method_index, paths = Gelauto.paths)
      @method_index = method_index
      @paths = paths
    end

    def to_s
      StringIO.new.tap { |io| compose(method_groups, io) }.string
    end

    private

    def method_groups
      @method_groups ||= { methods: [], children: {} }.tap do |groups|
        Utils.each_absolute_path(paths) do |path|
          method_index.each_method_in(path) do |_lineno, md|
            cur_group = md.nesting.inject(groups) do |group, namespace|
              group[:children][[namespace.name, namespace.type]] ||= { methods: [], children: {} }
            end

            cur_group[:methods] << md
          end
        end
      end
    end

    def compose(h, io, indent_level = 0)
      io.write(indent(h[:methods].map { |md| md.to_rbi }.join("\n\n"), indent_level))

      h[:children].each_with_index do |((namespace, type), next_level), idx|
        io.write("\n\n") if idx > 0
        io.write(indent("#{type} #{namespace}", indent_level))
        io.write("\n")
        compose(next_level, io, indent_level + 1)
        io.write("\n")
        io.write(indent('end', indent_level))
      end
    end

    def indent(str, indent_level)
      str.split("\n").map { |s| "#{'  ' * indent_level}#{s}" }.join("\n")
    end
  end
end
