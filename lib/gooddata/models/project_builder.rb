# encoding: UTF-8

require_relative 'dashboard_builder'
require_relative 'schema_builder'

module GoodData
  module Model
    class ProjectBuilder
      attr_reader :title, :datasets, :reports, :metrics, :uploads, :users, :assert_report, :date_dimensions

      class << self
        # Create from data/blueprint
        # @param blueprint Project blueprint
        # @param title Optional title of the project
        def create_from_data(blueprint, title = 'Title')
          pb = ProjectBuilder.new(title)
          pb.data = blueprint.to_hash
          pb
        end

        # Creates new project
        # @param title Title of the project
        # @param options Additional options
        # @param block Block
        def create(title, options={}, &block)
          pb = ProjectBuilder.new(title)
          block.call(pb)
          pb
        end
      end

      # Creates new instance of the ProjectBuilder
      # @param title Name of the project
      def initialize(title)
        @title = title
        @datasets = []
        @reports = []
        @assert_tests = []
        @metrics = []
        @uploads = []
        @users = []
        @dashboards = []
        @date_dimensions = []
      end

      # Add date dimension
      # @param name Name of the date dimension
      def add_date_dimension(name, options = {})
        dimension = {
          urn: options[:urn],
          name: name,
          title: options[:title]
        }

        @date_dimensions << dimension
      end

      # Add dataset
      # @param name Name of the dataset
      def add_dataset(name, &block)
        builder = GoodData::Model::SchemaBuilder.new(name)
        block.call(builder)
        if @datasets.any? { |item| item[:name] == name }
          ds = @datasets.find { |item| item[:name] == name }
          index = @datasets.index(ds)
          stuff = GoodData::Model.merge_dataset_columns(ds, builder.to_hash)
          @datasets.delete_at(index)
          @datasets.insert(index, stuff)
        else
          @datasets << builder.to_hash
        end
      end

      # Add report
      # @param title Report Title
      def add_report(title, options={})
        @reports << {:title => title}.merge(options)
      end

      # Add metric
      # @param title Title of the metric
      def add_metric(title, options={})
        @metrics << {:title => title}.merge(options)
      end

      # Add dashboard
      # @param title Title of the dashboard
      def add_dashboard(title, &block)
        db = DashboardBuilder.new(title)
        block.call(db)
        @dashboards << db.to_hash
      end

      # Load metric from file
      # @param file File with serialized metric
      def load_metrics(file)
        new_metrics = MultiJson.load(open(file).read, :symbolize_keys => true)
        @metrics = @metrics + new_metrics
      end

      # Load datasets from file
      # @param file File with datasets
      def load_datasets(file)
        new_metrics = MultiJson.load(open(file).read, :symbolize_keys => true)
        @datasets = @datasets + new_metrics
      end

      def assert_report(report, result)
        @assert_tests << {:report => report, :result => result}
      end

      # Upload data
      # @param data Data to be uploaded
      def upload(data, options={})
        mode = options[:mode] || 'FULL'
        dataset = options[:dataset]
        @uploads << {
          :source => data,
          :mode => mode,
          :dataset => dataset
        }
      end

      # Add users to project
      # @param users Users to be addded
      def add_users(users)
        @users << users
      end

      # Serializes project to its JSON representation
      # @param options To JSON serialization options
      def to_json(options={})
        eliminate_empty = options[:eliminate_empty] || false

        if eliminate_empty
          JSON.pretty_generate(to_hash.reject { |k, v| v.is_a?(Enumerable) && v.empty? })
        else
          JSON.pretty_generate(to_hash)
        end
      end

      # Serialize project to hash
      def to_hash
        {
          :title => @title,
          :datasets => @datasets,
          :uploads => @uploads,
          :dashboards => @dashboards,
          :metrics => @metrics,
          :reports => @reports,
          :users => @users,
          :assert_tests => @assert_tests,
          :date_dimensions => @date_dimensions
        }
      end

      # Get dataset by name
      # @param name Name of dataset to get
      def get_dataset(name)
        datasets.find { |d| d.name == name }
      end
    end
  end
end
