class EstimationValuesController < ApplicationController
  helper_method :show_notes

  def add_note_to_attribute
    @estimation_value = EstimationValue.find(params[:estimation_value_id])
  end

  def update
    @estimation_value = EstimationValue.find(params[:id])
    @estimation_value.notes =  show_notes(params["estimation_value"]["notes"], @estimation_value.notes.to_s.length)
    if @estimation_value.save
      flash[:notice] = I18n.t(:notice_notes_successfully_updated)
    else
      flash[:error] = I18n.t(:errors)
    end

    redirect_to :back
  end

  def show_notes(notes, current_note_length)
    user_infos = ""
    if current_note_length == 0
      user_infos = "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name} \r\n \r\n"
      user_infos << "_____________________________________________________________________________________ \r\n \r\n"
    else
      user_infos = "#{I18n.l(Time.now)} : #{I18n.t(:notes_updated_by)}  #{current_user.name} \r\n"
    end
    notes.prepend(user_infos)
  end

end

