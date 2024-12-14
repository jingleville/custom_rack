# frozen_string_literal: true

require_relative 'controllers/base_controller'

class RouteTree
  def initialize
    @root = RouteNode.new
  end

  def add_route(_method, path, handler)
    segments = path.split('/').reject(&:empty?)
    current_node = @root

    segments.each do |segment|
      current_node = current_node.add_child(segment)
    end

    current_node.handler = handler
  end

  def find_route(_method, path)
    segments = path.split('/').reject(&:empty?)
    current_node = @root

    params = {}

    segments.each do |segment|
      if current_node.children[segment]
        current_node = current_node.children[segment]
      elsif (dynamic_segment = current_node.children.find { |k, _| k.start_with?(':') })
        params[dynamic_segment[0][1..].to_sym] = segment
        current_node = dynamic_segment[1]
      else
        return nil, {}
      end
    end

    [current_node.handler, params]
  end
end

class RouteNode
  attr_accessor :segment, :children, :handler

  def initialize(segment = '', handler = nil)
    @segment = segment
    @children = {}
    @handler = handler
  end

  def add_child(segment, handler = nil)
    @children[segment] ||= RouteNode.new(segment, handler)
  end
end

module Router
  @@route = RouteTree.new

  def self.draw(ancestor = nil, &block)
    instance_eval(&block)
    @@route
  end

  def self.get(path, to)
    @@route.add_route('GET', path, to)
  end

  def self.post
    @@route.add_route('POST', path, to)
  end

  def self.routes
    @@route
  end

  def self.action_map
    {
      index:   { method: :get,    path: '/' },
      show:    { method: :get,    path: '/:id' },
      new:     { method: :get,    path: '/new' },
      edit:    { method: :get,    path: '/:id/edit' },
      create:  { method: :post,   path: '/' },
      update:  { method: :patch,  path: '/:id' },
      destroy: { method: :delete, path: '/:id' }
    }
  end

  def self.resources(handler, options = {}, ancestor = nil, &block)
    binding.irb

    except_options = options[:except] || []
    only_options = options[:only] || []

    allowed_methods = %i[ index show new edit create update destroy ].difference(except_options)
    allowed_methods = only_options.intersection(allowed_methods) if options[:only] != []

    allowed_methods.map do |option|
      option_data = action_map.fetch(option, nil)

      next if option_data.nil?

      full_path = ['/', handler, option_data[:path]].join
      handler_controller = "#{handler.capitalize}Controller##{option}"

      self.send(option_data[:method], full_path, handler_controller)
    end

    # Если есть вложенный блок, передаём контекст родительского ресурса
    if block_given?
      ancestor = { parent_name: name, parent_param: "#{name.to_s}_id" }
      yield(ancestor)
    end
  end

  def self.resource(handler, options = {})
    if options[:except].nil?
      options.merge({except: [:index]})
    else
      options[:except] = (options[:except] << :index).uniq
    end

    resources handler, options
  end
end
