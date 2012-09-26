#encoding: utf-8
class GroupsController < ApplicationController

  # GET /groups
  # GET /groups.json
  def index
    authorize! :edit_groups, Group
    set_page_title "Groups"
    @groups = Group.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    authorize! :edit_groups, Group
    set_page_title "New group"
    @group = Group.new
    @users = User.all
    @projects = Project.all

    respond_to do |format|
      format.html # _new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    authorize! :edit_groups, Group
    set_page_title "Edit group"
    @group = Group.find(params[:id])
    @users = User.all
    @projects = Project.all
  end

  # POST /groups
  # POST /groups.json
  def create
    authorize! :edit_groups, Group
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        format.html { redirect_to groups_path, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to groups_path, notice: 'Group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :ok }
    end
  end
  
end
