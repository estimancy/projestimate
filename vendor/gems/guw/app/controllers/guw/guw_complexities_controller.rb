class Guw::GuwComplexitiesController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_complexities = @guw_type.guw_complexities
  end

  def new
    @guw_complexity = Guw::GuwComplexity.new
  end

  def edit
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
  end

  def create
    @guw_complexity = Guw::GuwComplexity.new(params[:guw_complexity])
    @guw_complexity.save
    redirect_to main_app.root_url
  end

  def update
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_complexity.update_attributes(params[:guw_complexity])
    redirect_to main_app.root_url
  end
end
