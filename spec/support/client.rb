require 'sorbet-runtime'

module GelautoSpecs
  class Response
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
    end

    def to_a
      [status, body]
    end
  end

  class Client
    attr_reader :url, :username

    def initialize(options = {})
      @url = options[:url]
      @username = options[:username]
    end

    def request(body, headers = {})
      Response.new(200, 'it worked!')
    end
  end
end

Gelauto.paths << __FILE__
