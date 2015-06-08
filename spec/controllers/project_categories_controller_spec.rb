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

describe ProjectCategoriesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      get 'edit', {:id => @project_category.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      expect { delete 'destroy',:id => @project_category.id}.to change(ProjectCategory, :count).by(-1)
      response.should redirect_to project_categories_path
    end
  end

  describe 'Update' do
    it 'update project_category' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      put 'update', { :id => @project_category.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'create project_category' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      post 'create', { :id => @project_category.id }
      response.code.should eq "200"
    end
  end

end