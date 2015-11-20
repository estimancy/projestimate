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
    set_page_title I18n.t(:translations)
    authorize! :manage_master_data, :all

    I18n.backend.send(:init_translations)
    if params[:locale].nil?
      @translations = I18n.backend.send(:translations)[session[:current_locale].to_sym]
    else
      @translations = I18n.backend.send(:translations)[params[:locale].to_sym]
    end
    @available_locales = I18n.backend.send(:available_locales)
  end

  def call_my_recursive_friend(f, key, value, index)
    tabulation = index > 1 ? "  " : ""
    index.times do tabulation += "  " end
    f.puts("#{tabulation}#{key}:")
    value.each do |sub_key, val|

      if val.is_a?(Hash)
        f.puts("#{tabulation}  #{sub_key}:")
        val.each do |sub_key_prime, sub_val|
          if sub_val.is_a?(Hash)
            call_my_recursive_friend(f, sub_key_prime, sub_val, index.to_i + 2)
          elsif sub_val.is_a?(Array) && sub_val.length > 1
            f.puts("#{tabulation}  #{sub_key_prime}:")
            sub_val.each do |sub_val_prime|
              f.puts("#{tabulation}    - #{sub_val_prime.nil? ? "~" : sub_val_prime}")
            end
          else
            f.puts("#{tabulation}    #{sub_key_prime}: \"#{sub_val}\"")
          end
        end

      elsif val.is_a?(Array) && val.length > 1
        f.puts("#{tabulation}  #{sub_key}:")
        val.each do |sub_val|
          f.puts("#{tabulation}    - #{sub_val.nil? ? "~" : sub_val}")
        end
      else
        f.puts("#{tabulation}#{sub_key}: \"#{val}\"")
      end
    end
  end

  #Create a new entry
  def create

    locale = params[:available_locales].to_sym
    modified_hash = params[:translations]
    begin
      f = File.new("./config/locales/#{locale}.yml", "w")
      save_file = f
      f.puts("#{locale}:")
      modified_hash.each do |key, value|
        if value[0] == "{" && value[value.size - 1] == "}"
            my_eval = eval(value)
          if my_eval.is_a?(Hash)
            #toto = 42
            call_my_recursive_friend(f, key, my_eval, 1)
          end
        else
          f.puts("  #{key}: \"#{value}\"")
        end
      end
      f.close
    rescue Exception => exc
      f.close
      flash[:error] = "YOU SHALL NOT PASS ! ! ! !"
    end

    #deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
    #merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    #translations[locale].merge!(data, "tuto")
=begin
    authorize! :manage_master_data, :all

    params[:translations].each do |elem|
      I18n.backend.store_translations(:trol, { elem[0] => elem[1].first })
    end
    Translate::Storage.new(:trol).write_to_file
=end
    redirect_to translations_url, :notice => "#{I18n.t(:notice_translation_successful_added)}"

  end

  #Load translations from config/locale/*.yml files
  def load_translations
    @translations = I18n.backend.send(:translations)[params[:locale].to_sym]
  end

end
