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

describe WbsActivitiesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it 'returns http success' do
      @wbs_activity = FactoryGirl.create(:wbs_activity)
      get 'edit', {:id => @wbs_activity.id}
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it 'returns http success' do
      get 'new'
      response.should be_success
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @wbs_activity = FactoryGirl.create(:wbs_activity)
      expect { delete 'destroy', :id => @wbs_activity.id}.to change(WbsActivity, :count).by(-1)
      response.should render_template('index')
    end
  end

end
