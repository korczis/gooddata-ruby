# encoding: utf-8

module GoodData
  module Rest
    # Base class dealing with REST endpoints
    #
    # MUST Be interface for objects dealing with REST endpoints
    # MUST provide way to work with remote REST-like API in unified manner.
    # MUST NOT create new connections.
    class Object
      def initialize
        super
      end
    end
  end
end