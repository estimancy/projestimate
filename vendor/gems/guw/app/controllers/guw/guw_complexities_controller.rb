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
    redirect_to guw.guw_model_path(@guw_complexity.guw_type.guw_model)
  end

  def update
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_complexity.update_attributes(params[:guw_complexity])
    redirect_to guw.guw_model_path(@guw_complexity.guw_type.guw_model)
  end

  def destroy
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    model_id = @guw_complexity.guw_type.guw_model
    @guw_complexity.delete
    redirect_to guw.guw_model_path(model_id)
  end
end
