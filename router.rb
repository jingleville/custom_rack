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

class Router
  @@route = RouteTree.new

  def self.draw(&block)
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
end
