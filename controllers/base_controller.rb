# frozen_string_literal: true

module Controllers
  class BaseController
    def call(_request_params)
      ['200', { 'Content-Type' => 'text/plain' }, ['Hello World!']]
    end

    def test(_request_params)
      ['200', { 'Content-Type' => 'text/plain' }, ['this was a test']]
    end
  end
end
