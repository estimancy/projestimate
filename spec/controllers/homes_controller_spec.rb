# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

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

      #it 'should not return flash error message' do
      #  get 'update_install'
      #  unless defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
      #    expect(flash[:error]).to be_nil
      #  end
      #end
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
