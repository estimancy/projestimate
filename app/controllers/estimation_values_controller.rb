class EstimationValuesController < ApplicationController
  helper_method :show_notes

  def add_note_to_attribute
    @estimation_value = EstimationValue.find(params[:estimation_value_id])
  end

  def update
    @estimation_value = EstimationValue.find(params[:id])
    @estimation_value.notes =  show_notes(params["estimation_value"]["notes"])
    if @estimation_value.save
      flash[:notice] = I18n.t(:notice_notes_successfully_updated)
    else
      flash[:error] = I18n.t(:errors)
    end

    redirect_to :back
  end

  def show_notes(notes)
    user_infos = "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name} \r\n"
    notes.prepend(user_infos)
  end

end

