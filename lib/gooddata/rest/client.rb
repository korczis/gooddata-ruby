# encoding: utf-8

require_relative 'connections/connections'
require_relative 'object_factory'

module GoodData
  module Rest
    # User's interface to GoodData Platform.
    #
    # MUST provide way to use - DELETE, GET, POST, PUT
    # SHOULD provide way to use - HEAD, Bulk GET ...
    # SHOULD wrap some existing library/gem - RestClient, Typhoeus
    class Client
      #################################
      # Constants
      #################################
      DEFAULT_CONNECTION_IMPLEMENTATION = Connections::DummyConnection

      #################################
      # Class variables
      #################################
      @@instance = nil

      #################################
      # Getters/Setters
      #################################

      # Decide if we need provide direct access to connection
      attr_reader :connection

      # TODO: Decide if we need provide direct access to factory
      attr_reader :factory

      #################################
      # Class methods
      #################################
      class << self
        # Globally available way to connect (and create client and set global instance)
        #
        # ## HACK
        # To make transition from old implementation to new one following HACK IS TEMPORARILY ENGAGED!
        #
        # 1. First call of #connect sets the GoodData::Rest::Client.instance (static, singleton instance)
        # 2. There are METHOD functions with same signature as their CLASS counterparts using singleton instance
        #
        # ## Example
        #
        # client = GoodData.connect('jon.smith@goodddata.com', 's3cr3tp4sw0rd')
        #
        # @param username [String] Username to be used for authentication
        # @param password [String] Password to be used for authentication
        # @return [GoodData::Rest::Client] Client
        def connect(username, password)
          res = Client.new(:username => username, :password => password)

          # HACK: This line assigns class instance if not done yet
          @@instance = res if res.nil?
          res
        end
      end

      # Constructor of client
      # @param opts [Hash] Client options
      # @option opts [String] :username Username used for authentication
      # @option opts [String] :password Password used for authentication
      def initialize(opts)
        # TODO: Decide if we want to pass the options directly or not
        # username = opts[:username]
        # password = opts[:password]

        # TODO: See previous TODO
        # Create connection
        @connection = DEFAULT_CONNECTION_IMPLEMENTATION.new(opts)

        # Create factory bound to previously created connection
        @factory = ObjectFactory.new(@connection)
      end

      # Gets resource by name
      def resource(res_name)
        puts "Getting resource '#{res_name}'"
        nil
      end
    end
  end
end
