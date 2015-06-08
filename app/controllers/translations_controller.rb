#encoding: utf-8
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

class TranslationsController < ApplicationController

  #Listing translations pages
  def index
    set_page_title "Translations"
    authorize! :manage_master_data, :all

    I18n.backend.send(:init_translations)
    if params[:locale].nil?
      @translations = I18n.backend.send(:translations)[session[:current_locale].to_sym]
    else
      @translations = I18n.backend.send(:translations)[params[:locale].to_sym]
    end
    @available_locales = I18n.backend.send(:available_locales)
  end

  #Create a new entry
  def create
    authorize! :manage_master_data, :all

    params[:translations].each do |elem|
      I18n.backend.store_translations(:fr, { elem[0] => elem[1].first })
    end
    Translate::Storage.new(:fr).write_to_file

    redirect_to translations_url, :notice => "#{I18n.t(:notice_translation_successful_added)}"
  end

  #Load translations from config/locale/*.yml files
  def load_translations
    authorize! :manage_master_data, :all

    @translations = I18n.backend.send(:translations)[params[:locale]]
  end

end
