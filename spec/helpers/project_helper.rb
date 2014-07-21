# encoding: UTF-8

# Global requires
require 'multi_json'

# Local requires
require 'gooddata/models/models'

module ProjectHelper
  PROJECT_ID ||= 'ghbpozicaidf1b9s0ohsa6msu7792c1k'
  PROJECT_URL ||= "/gdc/projects/#{PROJECT_ID}"

  class << self
    def get_default_project
      GoodData::Project[PROJECT_ID]
    end

    def delete_all_projects
      projects = GoodData::Project[:all]

      user = GoodData.user

      while !projects.empty?
        project = projects.shift
        should_delete =  project.author == user.uri
        project.delete if should_delete
      end

    end
  end
end
