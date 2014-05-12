# encoding: UTF-8

require_relative 'account_settings'

module GoodData
  class Domain
    attr_reader :name

    USERS_OPTIONS = { :offset => 0, :limit => 1000 }

    class << self
      # Looks for domain
      #
      # @param domain_name [String] Domain name
      # @return [String] Domain object instance
      def [](domain_name, options = {})
        fail "Using pseudo-id 'all' is not supported by GoodData::Domain" if domain_name.to_s == 'all'
        GoodData::Domain.new(domain_name)
      end

      # Adds user to domain
      #
      # @param domain [String] Domain name
      # @param login [String] Login of user to be invited
      # @param password [String] Default preset password
      # @return [Object] Raw response
      def add_user(domain, login, password)
        data = {
          :accountSetting => {
            :login => login,
            :firstName => 'FirstName',
            :lastName => 'LastName',
            :password => password,
            :verifyPassword => password,
            :email => login
          }
        }

        url = "/gdc/account/domains/#{domain}/users"
        GoodData.post(url, data)
      end

      # Finds user in domain by login
      #
      # @param domain [String] Domain name
      # @param login [String] User login
      # @return [GoodData::AccountSettings] User account settings
      def find_user_by_login(domain, login)
        url = "/gdc/account/domains/#{domain}/users?login=#{login}"
        tmp = GoodData.get url
        items = tmp['accountSettings']['items'] if tmp['accountSettings']
        if items && items.length > 0
          return GoodData::AccountSettings.new(items.first)
        end
        nil
      end

      # Returns list of users for domain specified
      # @param [String] domain Domain to list the users for
      # @param [Hash] opts Options.
      # @option opts [Number] :offset The subject
      # @option opts [Number] :limit From address
      def users(domain, opts = USERS_OPTIONS)
        result = []

        options = USERS_OPTIONS.merge(opts)

        tmp = GoodData.get("/gdc/account/domains/#{domain}/users?offset=#{options[:offset]}&limit=#{options[:limit]}")
        tmp['accountSettings']['items'].each do |account|
          result << GoodData::AccountSettings.new(account)
        end

        result
      end
    end

    def initialize(domain_name)
      @name = domain_name
    end

    # Adds user to domain
    #
    # @param login [String] Login of user to be invited
    # @param password [String] Default preset password
    # @return [Object] Raw response
    #
    # Example
    #
    # GoodData.connect 'tomas.korcak@gooddata.com' 'your-password'
    # domain = GoodData::Domain['gooddata-tomas-korcak']
    # domain.add_user 'joe.doe@example', 'sup3rS3cr3tP4ssW0rtH'
    #
    def add_user(login, password)
      GoodData::Domain.add_user(name, login, password)
    end

    # Finds user in domain by login
    #
    # @param login [String] User login
    # @return [GoodData::AccountSettings] User account settings
    def find_user_by_login(login)
      GoodData::Domain.find_user_by_login(name, login)
    end

    # List users in domain
    #
    # @param [Hash] opts Additional user listing options.
    # @option opts [Number] :offset Offset to start listing from
    # @option opts [Number] :limit Limit of users to be listed
    # @return [Array<GoodData::AccountSettings>] List of user account settings
    #
    # Example
    #
    # GoodData.connect 'tomas.korcak@gooddata.com' 'your-password'
    # domain = GoodData::Domain['gooddata-tomas-korcak']
    # pp domain.users
    #
    def users(opts = USERS_OPTIONS)
      GoodData::Domain.users(name, opts)
    end

    private

    # Private setter of domain name. Used by constructor not available for external users.
    #
    # @param domain_name [String] Domain name to be set.
    def name=(domain_name) # rubocop:disable TrivialAccessors
      @name = domain_name
    end
  end
end
