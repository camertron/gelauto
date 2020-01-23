require 'sorbet-runtime'

module GelautoSpecs
  class Request
    extend T::Sig
    sig { params(status: String, body: String).returns(T::Array[String]) }
    def to_a(status, body)
      [status, body]
    end

    def to_s(number)
      number&.to_s
    end
  end
end

Gelauto.paths << __FILE__
