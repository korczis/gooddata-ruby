# encoding: UTF-8

require_relative '../metadata'
require_relative 'metadata'

module GoodData
  class Report < GoodData::MdObject
    root_key :report

    class << self
      def resource_name
        'report'
      end

      # Method intended to get all objects of that type in a specified project
      #
      # @param options [Hash] the options hash
      # @option options [Boolean] :full if passed true the subclass can decide to pull in full objects. This is desirable from the usability POV but unfortunately has negative impact on performance so it is not the default
      # @return [Array<GoodData::MdObject> | Array<Hash>] Return the appropriate metadata objects or their representation
      def all(options = {})
        query('reports', Report, options)
      end

      # Create new report
      def create(options = {})
        title = options[:title]
        summary = options[:summary] || ''
        rd = options[:rd] || ReportDefinition.create(:top => options[:top], :left => options[:left])
        rd.save

        report = {
          'report' => {
            'content' => {
              'domains' => [],
              'definitions' => [rd.uri]
            },
            'meta' => {
              'tags' => '',
              'deprecated' => '0',
              'summary' => summary,
              'title' => title
            }
          }
        }
        # TODO: write test for report definitions with explicit identifiers
        report['report']['meta']['identifier'] = options[:identifier] if options[:identifier]
        Report.new report
      end
    end

    def results
      content['results']
    end

    # Gets definition by url, by default returns latest definition
    #
    # @return [GoodData::MdObject] Definition
    def definition(definition_url = latest_report_definition_uri)
      project_url = uri.split('/')[0...-2].join('/')
      GoodData::MdObject[definition_url, { :project => GoodData::Project[project_url], :class => GoodData::ReportDefinition }]
    end

    # Gets definitions
    def definitions
      uris = definitions_uris
      uris.map do |uri|
        raw = GoodData.get uri
        GoodData::ReportDefinition.new(raw)
      end
    end

    # Gets definitions URIs
    def definitions_uris
      content['definitions']
    end

    # Gets latest report definition
    def latest_report_definition
      GoodData::ReportDefinition[latest_report_definition_uri, :project => project]
    end

    # Gets uri of latest report definition
    def latest_report_definition_uri
      content['definitions'].last
    end

    # Removes all definitions EXCEPT the latest one
    def remove_definition(definition)
      def_uri = is_a?(GoodData::ReportDefinition) ? definition.uri : definition
      content['definitions'] = definitions.reject { |x| x == def_uri }
      self
    end

    # TODO: Cover with test. You would probably need something that will be able to create a report easily from a definition
    def remove_definition_but_latest
      to_remove = definitions_uris - [latest_report_definition_uri]
      to_remove.each do |uri|
        remove_definition(uri)
      end
      self
    end

    # Removes all report definitions except last one
    def purge_report_of_unused_definitions!
      full_list = definitions_uris
      remove_definition_but_latest
      purged_list = definitions_uris
      to_remove = full_list - purged_list
      save
      to_remove.each { |uri| GoodData.delete(uri) }
      self
    end

    def execute
      fail 'You have to save the report before executing. If you do not want to do that please use GoodData::ReportDefinition' unless saved?
      result = GoodData.post '/gdc/xtab2/executor3', 'report_req' => { 'report' => uri }
      data_result_uri = result['execResult']['dataResult']
      result = GoodData.get data_result_uri
      while result['taskState'] && result['taskState']['status'] == 'WAIT'
        sleep 10
        result = GoodData.get data_result_uri
      end
      ReportDataResult.new(GoodData.get data_result_uri)
    end

    def exportable?
      true
    end

    def export(format)
      result = GoodData.post('/gdc/xtab2/executor3', 'report_req' => { 'report' => uri })
      result1 = GoodData.post('/gdc/exporter/executor', :result_req => { :format => format, :result => result })
      png = GoodData.get(result1['uri'], :process => false)
      while png.code == 202
        sleep(1)
        png = GoodData.get(result1['uri'], :process => false)
      end
      png
    end
  end
end
