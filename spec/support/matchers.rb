module GelautoSpecs
  def self.arg_hash_to_arglist(params)
    Gelauto::ArgList.new.tap do |arg_list|
      params.each_pair do |name, type_info|
        arg_list << case type_info
          when Hash
            Gelauto::Var.new(name).tap do |v|
              v.types.merge!(type_hash_to_typeset(type_info))
            end
          else
            Gelauto::Var.new(name).tap do |v|
              Array(type_info).each { |t| v.types << Gelauto::Type.new(t) }
            end
        end
      end
    end
  end

  def self.type_hash_to_typeset(type_info)
    Gelauto::TypeSet.new.tap do |typeset|
      type_info.each_pair do |type, generics|
        type = Gelauto.types[type].new

        generics.each_pair do |generic_name, generic_type|
          type.generic_args[generic_name].merge!(
            case generic_type
              when Hash
                type_hash_to_typeset(generic_type)
              else
                type_array_to_typeset(Array(generic_type))
            end
          )
        end

        typeset << type
      end
    end
  end

  def self.type_array_to_typeset(params)
    Gelauto::TypeSet.new.tap do |typeset|
      params.each do |type_info|
        case type_info
          when Hash
            typeset.merge!(type_hash_to_typeset(type_info))
          when Array
            typeset.merge!(type_array_to_typeset(type_info))
          else
            typeset << Gelauto::Type.new(type_info)
        end
      end
    end
  end

  module AcceptMatcher
    extend RSpec::Matchers::DSL

    matcher :accept do |expected_params = {}|
      match do |actual_md|
        @expected_arg_list = GelautoSpecs.arg_hash_to_arglist(expected_params)
        @expected_arg_list.to_sig == actual_md.args.to_sig
      end

      failure_message do |actual_md|
        <<~END
          Expected: #{@expected_arg_list.to_sig}
               Got: #{actual_md.args.to_sig}
        END
      end
    end
  end

  module HandBackMatcher
    extend RSpec::Matchers::DSL

    matcher :hand_back do |*expected_types|
      match do |actual_md|
        @expected_typeset = GelautoSpecs.type_array_to_typeset(expected_types)
        @expected_typeset.to_sig == actual_md.return_types.to_sig
      end

      failure_message do |actual_md|
        <<~END
          Expected: #{@expected_typeset.to_sig}
               Got: #{actual_md.return_types.to_sig}
        END
      end
    end

    matcher :hand_back_void do
      match do |actual_md|
        actual_md.to_sig.end_with?('.void }')
      end

      failure_message do |actual_md|
        <<~END
          Expected: void
               Got: #{actual_md.return_types.to_sig}
        END
      end
    end
  end
end
