require 'spec_helper'

describe WbsActivityElement do

  before :each do
    @wbs_activity_element = FactoryGirl.create(:wbs_activity_element)
    @wbs_activity_element2 = FactoryGirl.create(:wbs_activity_element, :name=>1)
    @local_status = FactoryGirl.create(:local_status)
  end

  it 'should return wbs_activity name' do
    @wbs_activity_element.wbs_activity_name.should eql(@wbs_activity_element.wbs_activity.name)
  end

  it 'should be not valid without wbs-activity' do
    @wbs_activity_element2.wbs_activity.should_not be_nil
  end

  it 'should be valid' do
    @wbs_activity_element.should be_valid
  end

  describe 'On master' do
    it ' After Duplicate wbs activity element: record status should be proposed' do
      MASTER_DATA=true
      @wbs_activity_element2=@wbs_activity_element.amoeba_dup
      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        @wbs_activity_element2.record_status.name.should eql('Proposed')
      else
        @wbs_activity_element2.record_status.name.should eql('Local')
      end
    end
  end

  describe 'On local' do
    it 'After Duplicate wbs activity element: record status should be local' do
      MASTER_DATA=false
      @wbs_activity_element2 = @wbs_activity_element.amoeba_dup
      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        @wbs_activity_element2.record_status.name.should eql('Proposed')
      else
        @wbs_activity_element2.record_status.name.should eql('Local')
      end
    end
  end

  describe 'import' do
    before :each do
      @wbs_activity = FactoryGirl.create(:wbs_activity)
      @wbs_activity_element = FactoryGirl.create(:wbs_activity_element,:id=>261, :wbs_activity => @wbs_activity)
      @wbs_activity_element2 = FactoryGirl.create(:wbs_activity_element,:id=>262, :wbs_activity => @wbs_activity)
    end
    it 'should import wbs activity element without error' do
      expected_csv =  File.dirname(__FILE__) + '/../fixtures/test.csv'
      file=ActionDispatch::Http::UploadedFile.new({
                                                      :filename => 'test.csv',
                                                      :content_type => 'text/csv',
                                                      :tempfile => File.new(File.dirname(__FILE__) + '/../fixtures/test.csv')
                                                  })
      expect(WbsActivityElement::import(file,'')).to be_truthy
      # sometimes it is better to parse generated_csv (ie. when you testing other formats like json or xml
    end

    it 'should rebuild wbs activity' do
      expect(WbsActivityElement::rebuild([@wbs_activity_element,@wbs_activity_element2], @wbs_activity.id)).to be_truthy
    end
  end

end