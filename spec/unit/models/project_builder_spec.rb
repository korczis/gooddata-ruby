# encoding: UTF-8

require 'gooddata'

describe GoodData::Model::ProjectBuilder do
  describe '#create' do
    it 'Creates new instance of ProjectBuilder' do
      GoodData::Model::ProjectBuilder.create('test') do |p|
      end
    end
  end
end
