module Gelauto
  class MethodIndex
    attr_reader :index, :sig_index

    def initialize
      @index = Hash.new { |h, k| h[k] = {} }
      @sig_index = Hash.new { |h, k| h[k] = {} }
    end

    def index_methods_in(path, ast, nesting = [])
      return unless ast

      case ast.type
        when :def, :defs
          name = nil
          args = nil

          if ast.type == :def
            name = ast.children[0]
            args = ast.children[1].children.map { |c| c.children.first }
          else
            name = ast.children[1]
            args = ast.children[2].children.map { |c| c.children.first }
          end

          md = MethodDef.new(name, args, nesting)
          index[path][ast.location.name.line] = md

          # point to start of method
          index[path][ast.location.end.line] = ast.location.name.line

        when :class, :module
          const_name = ast.children.first.children.last
          return visit_children(path, ast, nesting + [Namespace.new(const_name, ast.type)])
        when :block
          if ast.children.first.children.last == :sig
            sig_index[path][ast.location.line] = true
          end
      end

      visit_children(path, ast, nesting)
    end

    def find(path, lineno)
      if md = index[path][lineno]
        return md if md.is_a?(MethodDef)

        # md is actually an index pointing to another line
        index[path][md]
      end
    end

    def each
      return to_enum(__method__) unless block_given?

      index.each_pair do |path, line_index|
        line_index.each_pair do |lineno, md|
          yield(path, lineno, md) if md.is_a?(MethodDef)
        end
      end
    end

    def each_method_in(path)
      return to_enum(__method__, path) unless block_given?

      index[path].each_pair do |lineno, md|
        yield lineno, md if md.is_a?(MethodDef)
      end
    end

    def annotate(path, code)
      lines = code.split(/\r?\n/)
      mds = index[path]
      sigs = sig_index[path]

      [].tap do |annotated|
        lines.each_with_index do |line, idx|
          lineno = idx + 1
          md = mds[lineno]

          if md.is_a?(MethodDef)
            next if sigs[idx]

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

    private

    def visit_children(path, ast, nesting)
      ast.children.each do |child|
        index_methods_in(path, child, nesting) if child.is_a?(Parser::AST::Node)
      end
    end
  end
end
