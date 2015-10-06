# encoding: UTF-8
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

require 'uuidtools'

namespace :estimancy do
  desc 'Load default data'
  task :my_load_data => :environment do

    Organization.delete_all
    10.times do |n|
      u = User.first
      o = Organization.new(name: Faker::Lorem.word,
                           number_hours_per_month: Faker::Number.positive,
                              cost_per_hour: Faker::Number.positive,
                              currency_id: Currency.first.id,
                              limit1: Faker::Number.number(2),
                              limit2: Faker::Number.number(2),
                              limit3: Faker::Number.number(2),
                              description: Faker::Book.title,
                              is_image_organization: 0,
                              number_hours_per_day: Faker::Number.positive,
                              inflation_rate: Faker::Number.positive,
                              limit4: Faker::Number.number(2),
                              limit1_coef: Faker::Number.positive,
                              limit2_coef: Faker::Number.positive,
                              limit3_coef: Faker::Number.positive,
                              limit4_coef: Faker::Number.positive,
                              limit1_unit: Faker::Name.suffix,
                              limit2_unit: Faker::Name.suffix,
                              limit3_unit: Faker::Name.suffix,
                              limit4_unit: Faker::Name.suffix)

      o.save(validate: true)

      OrganizationsUsers.create(user_id: u.id, organization_id: o.id)

    end
=begin
    Organization.all.each do |organization|
      10.times do
        Project.create()
      end
    end
=end
  end
end