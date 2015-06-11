class ApplicationsController < ApplicationController
  before_filter :set_application, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @applications = Application.all
    respond_with(@applications)
  end

  def show
    respond_with(@application)
  end

  def new
    @application = Application.new
    @organization = Organization.find(params[:organization_id])
    respond_with(@application)
  end

  def edit
    @organization = Organization.find(params[:organization_id])
  end

  def create
    @application = Application.new(params[:application])
    @application.save
    respond_with(@application)
  end

  def update
    @application.update_attributes(params[:application])
    respond_with(@application)
  end

  def destroy
    @application.destroy
    respond_with(@application)
  end

  private
    def set_application
      @application = Application.find(params[:id])
    end
end
