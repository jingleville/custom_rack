# frozen_string_literal: true

require 'json'
require_relative 'routes'
require_relative 'router'

class Application
  ERRORS = {
    400 => [
      400,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Bad Request',
          "message": 'Invalid request parameters.'
        }.to_json
      ]
    ],
    401 => [
      401,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Unauthorized',
          "message": 'Authentication is required to access this resource.'
        }.to_json
      ]
    ],
    403 => [
      403,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Forbidden',
          "message": 'You do not have permission to access this resource.'
        }.to_json
      ]
    ],
    404 => [
      404,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Not Found',
          "message": 'The requested resource could not be found.'
        }.to_json
      ]
    ],
    405 => [
      405,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Method Not Allowed',
          "message": 'This HTTP method is not supported for the requested resource.'
        }.to_json
      ]
    ],
    422 => [
      422,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Unprocessable Entity',
          "message": 'The provided data is invalid.'
        }.to_json
      ]
    ],
    500 => [
      500,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Internal Server Error',
          "message": 'An unexpected error occurred. Please try again later.'
        }.to_json
      ]
    ],
    503 => [
      503,
      { 'Content-Type' => 'application/json' },
      [
        {
          "error": 'Service Unavailable',
          "message": 'The server is currently unavailable. Please try again later.'
        }.to_json
      ]
    ]
  }.freeze

  def call(env)
    route(env)
  rescue StandardError => e
    puts e
    error(500)
  end

  private

  def route(env)
    routes = Router.routes

    request_method = env['REQUEST_METHOD']
    request_path = env['REQUEST_PATH']

    handler, params = routes.find_route(request_method, request_path)

    return error(404) unless handler

    controller_name, method_name = handler.split('#')

    return error(404) unless Object.const_defined? "Controllers::#{controller_name}"

    controller_class = Object.const_get("Controllers::#{controller_name}")
    controller_class.new.send(method_name, params)
  end

  def error(code)
    ERRORS.fetch(code, [400, { 'Content-Type' => 'text/plain' }, ['Unknown error']])
  end
end
