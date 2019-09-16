require 'webpagetest/connection'

module Webpagetest
  # Custom response class for Webpagetest test data
  class Response

    attr_reader :client, :test_id, :status, :result, :raw

    STATUS_BASE = 'testStatus.php'
    RESULT_BASE = 'jsonResult.php'

    def initialize(client, raw_response, running = true)
      @client = client
      @raw = raw_response

      if raw.data.id.present?
        set_status(raw.statusCode.to_s)
        set_test_id(running)
        set_result if status == :completed
      else
        @status = :running
        set_test_id(running)
      end
    end

    def ok?
      raw.respond_to?(:statusCode) && raw.statusCode == 200
    end

    # Gets the status of the request (code from Susuwatari gem)
    def get_status
      fetch_status unless status == :completed
      status
    end

    private

    # Check for the test id based on the status of the test
    def set_test_id(running)
      if !running && status == :completed
        @test_id = raw.data.id
      elsif raw.data
        @test_id = raw.data.testId
      else
        # When @test_id is nil, calling `get_status` will set @status to :error.
        @test_id = nil
      end
    end

    # Check 3 possible scenarios (code from Susuwatari gem)
    def set_status(status_code, fetch = false)
      case status_code
      when /1../
        @status = :running
      when "200"
        @status = :completed
        fetch_result if fetch
      when /4../
        @status = :error
      end
    end

    # Set the status code and text and save the raw data to the result ivar
    def set_result
      raw.data.status_code = raw.statusCode
      raw.data.status_text = raw.statusText
      @result = raw.data
    end

    # Makes the request to get the status of the test
    def fetch_status
      connection = @client.connection
      response = connection.get do |req|
        req.url STATUS_BASE
        req.params['f'] = :json
        req.params['test'] = test_id
      end
      response_body = Hashie::Mash.new(JSON.parse(response.body))

      set_status(response_body.data.statusCode.to_s, true)
    end

    # Makes the request to get the test result
    def fetch_result
      connection = @client.connection
      response = connection.get do |req|
        req.url RESULT_BASE
        req.params['test'] = test_id
        req.params['pagespeed'] = 1
      end
      response_body = HashieResponse.new(JSON.parse(response.body))
      response_body.data.status_code = response_body.statusCode
      response_body.data.status_text = response_body.statusText
      @result = response_body.data
    end

    include Connection
  end

  class HashieResponse < Hashie::Mash
    disable_warnings
  end
end
