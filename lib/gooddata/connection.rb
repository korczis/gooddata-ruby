# encoding: UTF-8

require_relative 'core/logging'

require_relative 'rest/rest'

module GoodData
  class << self
    DEFAULT_SSO_OPTIONS = {
      :url => '/gdc/app/account/bootstrap',
      :valid => 24 * 60 * 60
    }

    # Returns the active GoodData connection earlier initialized via GoodData.connect call
    #
    # @see GoodData.connect
    def connection
      # TODO: Remove this after successful rest-factory transition
      Rest::Client.connection # || fail('Please authenticate with GoodData.connect first')
    end

    alias_method :client, :connection

    # Connect to the GoodData API
    #
    # @param options
    # @param second_options
    # @param third_options
    #
    def connect(options = nil, second_options = nil, third_options = {})
      Rest::Client.connect(options, second_options, third_options)
    end

    def connect_sso(login, provider)
      Rest::Client.connect_sso(login, provider)

      # url = sso_url(login, provider, opts)
      # RestClient.get url do |response, request, result|
      #   cookies = response.cookies.dup
      #   # cookies.delete('GDCAuthSST')
      #   GoodData.connect(:cookies => response.cookies)
      # end
    end

    # Disconnect (logout) if logged in
    def disconnect
      Rest::Client.disconnect
    end

    def with_connection(options = nil, second_options = nil, third_options = {}, &bl)
      connection = connect(options, second_options, third_options)
      bl.call(connection)
    rescue Exception => e # rubocop:disable RescueException
      puts e.message
      raise e
    ensure
      disconnect
    end

    def sso_url(login, provider, opts = Rest::Client::DEFAULT_SSO_OPTIONS)
      Rest::Client.sso_url(login, provider, opts)
    end
  end
end
