module Gelauto
  class MethodIndex
    attr_reader :index

    def initialize
      @index = Hash.new { |h, k| h[k] = {} }
    end

    def index_methods_in(path, ast)
      return unless ast

      if ast.type == :def
        args = ast.children[1].children.map { |c| c.children.first }
        md = MethodDef.new(ast.children[0], args)
        index[path][ast.location.name.line] = md

        # point to start of method
        index[path][ast.location.end.line] = ast.location.name.line
      end

      ast.children.each do |child|
        index_methods_in(path, child) if child.is_a?(Parser::AST::Node)
      end
    end

    def find(path, lineno)
      if md = index[path][lineno]
        return md if md.is_a?(MethodDef)

        # md is actually an index pointing to another line
        index[path][md]
      end
    end

    def each
      index.each_pair do |path, line_index|
        line_index.each_pair do |lineno, md|
          yield(path, lineno, md) if md.is_a?(MethodDef)
        end
      end
    end

    def annotate(path, code)
      lines = code.split(/\r?\n/)
      mds = index[path]

      [].tap do |annotated|
        lines.each_with_index do |line, idx|
          lineno = idx + 1
          md = mds[lineno]

          if md.is_a?(MethodDef)
            indent = line[0...line.index(/[^\s]/)]
            annotated << "#{indent}#{md.to_sig}"
          end

          annotated << line
        end
      end.join("\n")
    end

    def reset
      index.clear
    end
  end
end
