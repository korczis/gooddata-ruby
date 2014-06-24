# encoding: UTF-8

require 'gooddata'

describe GoodData::Dashboard, :dashboard => true do
  before(:each) do
    ConnectionHelper::create_default_connection
  end

  after(:each) do
    GoodData.disconnect
  end

  describe '#author' do
    it 'Returns author as GoodData::Profile' do
      dashboard = DashboardHelper.default_dashboard

      res = dashboard.author
      expect(res).to be_instance_of(GoodData::Profile)
    end
  end

  describe '#contributor' do
    it 'Returns contributor as GoodData::Profile' do
      dashboard = DashboardHelper.default_dashboard

      res = dashboard.contributor
      expect(res).to be_instance_of(GoodData::Profile)
    end
  end

  describe '#created' do
    it 'Returns date when created as Time' do
      dashboard = DashboardHelper.default_dashboard

      res = dashboard.created
      expect(res).to be_instance_of(Time)
    end
  end

  describe '#title' do
    it 'Returns title as String' do
      dashboard = DashboardHelper.default_dashboard

      res = dashboard.title
      expect(res).to be_instance_of(String)
    end
  end

  describe '#updated' do
    it 'Returns date when updated as Time' do
      dashboard = DashboardHelper.default_dashboard

      res = dashboard.updated
      expect(res).to be_instance_of(Time)
    end
  end
end