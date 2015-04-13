class Guw::GuwComplexitiesController < ApplicationController

  def index
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
    @guw_type = Guw::GuwType.find(params[:guw_type_id])
    @guw_complexities = @guw_type.guw_complexities
  end

  def new
    @guw_complexity = Guw::GuwComplexity.new
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
  end

  def edit
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_model = Guw::GuwModel.find(params[:guw_model_id])
  end

  def create
    @guw_complexity = Guw::GuwComplexity.new(params[:guw_complexity])

    @guw_type = Guw::GuwType.find(params[:guw_complexity][:guw_type_id])

    @guw_complexity.bottom_range = params[:guw_complexity][:bottom_range].to_i
    @guw_complexity.top_range = params[:guw_complexity][:top_range].to_i

    @guw_complexity.save
    redirect_to guw.guw_model_path(@guw_complexity.guw_type.guw_model, anchor: "tabs-#{@guw_complexity.guw_type.name.gsub(" ", "-")}")
  end

  def update
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    @guw_type = Guw::GuwType.find(params[:guw_complexity][:guw_type_id])
    @guw_complexity.update_attributes(params[:guw_complexity])
    redirect_to guw.guw_model_path(@guw_complexity.guw_type.guw_model, anchor: "tabs-#{@guw_type.name.gsub(" ", "-")}")
  end

  def destroy
    @guw_complexity = Guw::GuwComplexity.find(params[:id])
    model_id = @guw_complexity.guw_type.guw_model
    @guw_complexity.delete
    redirect_to guw.guw_model_path(model_id)
  end
end
