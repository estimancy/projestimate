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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

#Some helper for the app...
module ApplicationHelper
  include InputsHelper
  def pop_up(id, title, to_container=true, &block)
		content_tag(:div, { :class => 'pop_up', :style => 'display: none;', :id => id }) do
			res = content_tag(:div, { :class => 'pop_up_title_bar'}) do
				content_tag(:h1, title) + link_to_function('X', "hide_popup('#{id}')", :class => 'pop_up_close_button')
			end

			res += capture(&block) if block_given?
			res
		end
  end

  def javascript_heads
    tags =javascript_tag("$(window).load(function(){ warn_me('#{escape_javascript I18n.t (:text_warn_on_leaving_unsaved)}'); });")
    tags
  end

end
