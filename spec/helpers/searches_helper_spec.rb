require 'spec_helper'

describe SearchesHelper do

  before :each do
    @sloc_attribute = FactoryGirl.create(:sloc_attribute)
  end

  it "should display link" do
    display_link(@sloc_attribute, "toto").should == "<a href=\"/pe_attributes/#{@sloc_attribute.id}/edit\" class=\"search_result\" style=\"font-size:12px; color: #467aa7;\">Sloc1 (sloc1)</a>"
  end

  it "should display description" do
    display_description(@sloc_attribute, "toto").should == "Attribute number 1"
  end

  it "should display last updated date" do
    display_update(@sloc_attribute).should ==  "#{I18n.t(:text_latest_update)} #{I18n.l(@sloc_attribute.updated_at)}"
  end

end
