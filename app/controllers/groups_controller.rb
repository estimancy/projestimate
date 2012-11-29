#encoding: utf-8
#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012 Spirula (http://www.spirula.fr)
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
########################################################################

class GroupsController < ApplicationController

  def index
    authorize! :edit_groups, Group
    set_page_title "Groups"
    @groups = Group.all
  end

  def new
    authorize! :edit_groups, Group
    set_page_title "New group"
    @group = Group.new
    @users = User.all
    @projects = Project.all
  end

  def edit
    authorize! :edit_groups, Group
    set_page_title "Edit group"
    @group = Group.find(params[:id])
    @users = User.all
    @projects = Project.all
  end

  def create
    authorize! :edit_groups, Group
    @group = Group.new(params[:group])
    if @group.save
      redirect_to redirect(groups_path)
    else
      redirect_to redirect(new_group_path)
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      redirect_to redirect(groups_path)
    else
      redirect_to redirect(edit_group_path(@group))
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_url
  end
end
