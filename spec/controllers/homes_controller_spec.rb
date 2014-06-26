require 'spec_helper'

describe HomesController do
  #end
  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe "GET 'update_install'" do
    context 'On local instance' do
      it 'returns http success and the flash notice message' do
        get 'update_install'
        unless defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
          ['Projestimate data have been updated successfully.', 'You already have the latest MasterData.', nil].should include(flash[:notice])
        end
      end

      it 'should not return flash error message' do
        get 'update_install'
        unless defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
          expect { flash[:error] }.to be_nil
        end
      end
    end

    context 'On master instance' do
      #it "returns http success" do
      #  get 'update_install'
      #  flash[:notice].should eq("Projestimate data have been updated successfully.")
      #  flash[:error].should be_nil
      #end
    end

  end

end
