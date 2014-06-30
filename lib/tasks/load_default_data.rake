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

require 'uuidtools'

namespace :projestimate do
  desc 'Load default data'
  task :load_default_data => :environment do

    print "\n-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-\n"
    print "\n-!-!-!- This is a deprecated task ... let we recommend to QUIT (option 3) -!-!-!-\n"
    print "\n-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-!-\n\n"
    print "\n You're about to install the default data on #{Rails.env} database. Do you want : \n
       1- Delete all data then reinstall default data -- Press 1 \n
       2- Reinstall default data and keep old data (recommended) -- Press 2 \n
       3- Do nothing and quit the prompt -- Press 3 or Ctrl + C \n
    \n"

    i = true
    while i do
      STDOUT.flush
      response = STDIN.gets.chomp!

      if response == '1'
        are_you_sure? do
          puts "Deleting all data...\n"
          tables = []
          ActiveRecord::Base.connection.execute('show tables').each { |r| tables << r[0] }
          tables = tables - ['schema_migrations']
          tables.each do |table|
            ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
          end

          load_data!
        end
        i = false
      elsif response == '2'
        are_you_sure? do
          load_data!
        end
        i = false
      elsif response == '3'
        puts 'Nothing to do. Bye.'
        i = false
      end
    end
  end
end

private
def load_data!
  #begin
  puts ' Creating Master Parameters ...'

    # Version
    puts '   - Version table'
    Version.create :comment => 'No update data has been save'

    #RecordStatus
    record_status = Array.new
    record_status = [
        ['Proposed', 'TBD'],
        ['InReview', 'TBD'],
        ['Draft', 'TBD'],
        ['Defined', 'TBD'],
        ['Retired', 'TBD'],
        ['Custom', 'TBD'],
        ['Local', 'TBD']
    ]
    record_status.each do |i|
      RecordStatus.create(:name => i[0], :description => i[1] )
    end

    #Find correct record status id
    rsid = RecordStatus.find_by_name('Defined').id

    puts '   - Record Status'
    #Update record status to "Defined"
    record_statuses = RecordStatus.all
    record_statuses.each do |rs|
      rs.update_attribute(:record_status_id, rsid)
    end

  puts '   - Currencies'
    Currency.create(:name => 'Euro', :alias => 'euros', :description => 'European Union currency', :iso_code => 'EUR', :iso_code_number => '978', :sign => '€', :conversion_rate => 1.000000, :record_status_id => rsid)
    Currency.create(:name => 'Dollar', :alias => 'dollars', :description => 'United State Dollar', :iso_code => 'USD', :iso_code_number => '840', :sign => '$', :conversion_rate => 1.312100, :record_status_id => rsid)
    Currency.create(:name => 'Pound', :alias => 'pounds', :description => 'Great Britain currency', :iso_code => 'GBP', :iso_code_number => '826', :sign => '£', :conversion_rate => 0.851000, :record_status_id => rsid)


    puts '   - Project areas'
    #Default project area
    ProjectArea.create(:name => 'SW Project', :description => 'Software', :record_status_id => rsid)
    pjarea=ProjectArea.first

    puts '   - Project categories'
    ProjectCategory.create(:name => 'Unknown', :description => 'TBD', :record_status_id => rsid)
    #pjcategory=ProjectCategory.first
    ProjectCategory.create(:name => 'Multimedia', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Network Management', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Office Automation', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Relational Database', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Report Generation', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'System & Device Utilities', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Transaction Processing', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Robotics', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Simulation', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Software Development Tools', :description => 'TBD', :record_status_id => rsid)
    ProjectCategory.create(:name => 'Workflow', :description => 'TBD', :record_status_id => rsid)

    puts '   - Platform categories'
    PlatformCategory.create(:name => 'Unknown', :description => 'TBD', :record_status_id => rsid)
    #plcategory=PlatformCategory.first
    PlatformCategory.create(:name => 'Client-Server', :description => 'TBD', :record_status_id => rsid)
    PlatformCategory.create(:name => 'Mobile Ground-Based', :description => 'TBD', :record_status_id => rsid)
    PlatformCategory.create(:name => 'Server', :description => 'TBD', :record_status_id => rsid)
    PlatformCategory.create(:name => 'Telecommunications', :description => 'TBD', :record_status_id => rsid)
    PlatformCategory.create(:name => 'Web Based Development', :description => 'TBD', :record_status_id => rsid)

    puts '   - Acquisition categories'
    #Default acquisition category
      acquisition_category = Array.new
      acquisition_category = [
        ['Unknown', 'TBD'],
        ['New Development', 'TBD'],
        ['Enhancement', 'TBD'],
        ['Re-development', 'TBD'],
        ['POC', 'TBD'],
        ['Purchased', 'TBD'],
        ['Porting', 'TBD'],
        ['Other', 'TBD']
      ]

      acquisition_category.each do |i|
        AcquisitionCategory.create(:name => i[0], :description => i[1], :record_status_id => rsid)
      end
      #accategory=AcquisitionCategory.first
      
    puts '   - Attributes'
      attributes = [
      ['KSLOC', 'ksloc', 'Kilo (1000) Source Lines Of Code.', 'float', ['float','>=', '0'], 'sum', nil],
      ['Cost', 'cost', 'Cost of a product, a service or a process in local currency', 'float', ['float','>=', '0'], 'sum', nil],
      ['Delay', 'delay', 'Time allowed for the completion of something in number of days', 'float', ['float','>=', '0'], 'average', nil],
      ['Staffing', 'staffing', 'Staff required to accomplish a task in number of people', 'integer', ['integer','>=', '0'], 'sum', nil],
      ['Staffing complexity', 'staffing_complexity', "A rating of the project's inherent difficulty in terms of the rate at which staff are added to a project.", 'float', ['float','>=', '0'], 'average', nil],
      ['Effective technology', 'effective_technology', 'A composite metric that captures factors relating to the efficiency or productivity with which development can be carried out.', 'float', ['float','>=', '0'], 'average', nil],
      ['End date', 'end_date', 'End date for a task, a pbs_project_element. Dependent of delay.', 'date', ['date'], 'maxi', nil],
      ['Effort Man Hour', 'effort_man_hour', 'A man-hour or person-hour is the amount of work performed by an average worker in one hour.', 'float', ['float','>=', '0'], 'average', nil],
      ['Effort Man Month', 'effort_man_month', 'A man-month or person-month is the amount of work performed by an average worker in one Month.', 'float', ['float','>=', '0'], 'average', nil],
      ['Duration', 'duration', 'Duration of a task in hour', 'float', ['float','>=', '0'], 'average', nil],
      ['Complexity', 'complexity', 'classes of software projects (for COCOMO modules) - Organic projects: "small" teams with "good" experience working with "less than rigid" requirements - Semi-detached projects: "medium" teams with mixed experience working with a mix of rigid and less than rigid requirements - Embedded projects: developed within a set of "tight" constraints. It is also combination of organic and semi-detached projects.(hardware, software, operational, ...)', 'list', ['list','','Organic;Semi-detached;Embedded'], 'average', true],
      ['Schedule', 'schedule', 'Schedule in calendar months', 'integer', ['integer', '>=', '0'], 'sum', nil],
      ['Defects', 'defects', 'Defects', 'integer', ['integer', '>=', '0'], 'sum', nil],
      ['Total Effort', 'total_effort', 'A man-hour or person-hour is the amount of work performed by an average worker in one hour for all activities.', 'float', ['float', '>=', '0'], 'average', nil],
      ['Methodology', 'methodology', 'Methodology M 1-5 1=none/CMMI Level 1 to 5-CMMI Level 5', 'integer', ['between', '0;5'], 'sum', nil],
      ['Note', 'note', 'A text note, for annotation, comment etc.', 'text', ['text'], nil],
      ['Platform Maturity', 'platform_maturity', 'Platform Maturity - 1 ou 2', 'integer', ['integer'], nil],
      ['Real-time Constraint', 'real_time_constraint', '1=not real time/desktop with no constraints - 10=mission critical/ssafety critical real time system', 'integer', ['integer'], nil],
      ['Sandbox Date', 'date_sandbox', 'Sample Date attribute for testing purpose', 'date', ['date'], nil],
      ['Sandbox Description', 'description_sandbox', 'Sample text attribute for testing purpose', 'text', ['text'], nil],
      ['Sandbox Float', 'float_sandbox', 'Sample Float attribute for testing purpose', 'float', ['float'], nil],
      ['Sandbox Integer', 'integer_sandbox', 'Sample Integer attribute for testing purpose', 'integer', ['integer'], nil],
      ['Sandbox List', 'list_sandbox', 'Sample List attribute for testing purpose', 'list', ['list', 'Un;Deux;Troix;Quatre;Cinq;Six;Sept'], nil],
    ]

    attributes.each do |i|
      PeAttribute.create(:name => i[0], :alias => i[1], :description => i[2], :attr_type => i[3], :options => i[4], :aggregation => i[5], :record_status_id => rsid, :single_entry_attribute => ( i[6] if i[6]) )
    end

  puts '   - Modules'
  modules=[
      ['initialization', 'initialization', 'The Initialization module.', 'no',]
  ]

  modules.each do |i|
    pemodule = Pemodule.new(:title => i[0], :alias => i[1], :description => i[2], :with_activities => 'no', :record_status_id => rsid)
    pemodule.save(validate: false)
  end

  # Get the Capitalization Module
  initialization_module = Pemodule.find_by_alias_and_record_status_id("initialization", rsid)

    puts '   - Estimancy Icons'

    folder = Peicon.create(:name => 'Folder', :icon => File.new("#{Rails.root}/public/folder.png"), :record_status_id => rsid)
    link = Peicon.create(:name => 'Link', :icon => File.new("#{Rails.root}/public/link.png", 'r'), :record_status_id => rsid)
    undefined = Peicon.create(:name => 'Undefined', :icon => File.new("#{Rails.root}/public/undefined.png", 'r'), :record_status_id => rsid)
    default = Peicon.create(:name => 'Default', :icon => File.new("#{Rails.root}/public/default.png", 'r'), :record_status_id => rsid)

    puts '   - WBS structure'
    #Create first work element type (type of a pbs_project_element)
    WorkElementType.create(:name => 'Folder', :alias => 'folder', :peicon_id => folder.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Link', :alias => 'link', :peicon_id => link.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Undefined', :alias => 'undefined', :peicon_id => undefined.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Developed Software', :alias => 'DevSW', :peicon_id => default.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Purchased Software', :alias => '$SW', :peicon_id => default.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Purchased Hardware', :alias => '$HW', :peicon_id => default.id, :record_status_id => rsid)
    WorkElementType.create(:name => 'Purchased Miscellaneous', :alias => '$SMisc', :peicon_id => default.id, :record_status_id => rsid)

    wet = WorkElementType.first
           
    puts '   - Currencies'
    # First need to fix Currency.delete_all 
    Currency.create(:name => 'Euro', :alias => 'EUR', :description => 'TBD')
    Currency.create(:name => 'US Dollar', :alias => 'USD', :description => 'TBD')
    Currency.create(:name => 'British Pound', :alias => 'GBP', :description => 'TBD')
    
    puts '   - Language...'
    #Create default language
    Language.create(:name => 'English (United States)', :locale => 'en', :record_status_id => rsid)
    Language.create(:name => 'Français (France)', :locale => 'fr', :record_status_id => rsid)
    Language.create(:name => 'English (British)', :locale => 'en-gb', :record_status_id => rsid)
    Language.create(:name => 'Deutsch (Deutschland)', :locale => 'de', :record_status_id => rsid)

  puts ' Creating Admin Parameters ...'
    
  puts '   - Admin setting'
    AdminSetting.create(:key => 'welcome_message', :value => 'Welcome aboard !', :record_status_id => rsid)
    AdminSetting.create(:key => 'notifications_email', :value => 'AdminEmail@domaine.com', :record_status_id => rsid)
    AdminSetting.create(:key => 'password_min_length', :value => '4', :record_status_id => rsid)
    AdminSetting.create(:key => 'url_wiki', :value => 'http://forge.estimancy.com/projects/pe/wiki', :record_status_id => rsid)
    AdminSetting.create(:key => 'url_service', :value => 'http://forge.estimancy.com/projects/pe/wiki/Community_Services', :record_status_id => rsid)
    as = AdminSetting.new(:key => 'custom_status_to_consider', :value => nil, :record_status_id => rsid, :uuid => UUIDTools::UUID.random_create.to_s)
    as.save(:validate => false)

    puts '   - Auth Method'
    authmethod = AuthMethod.new(:name => 'Application', :server_name => 'Not necessary', :port => 0, :base_dn => 'Not necessary', :certificate => 'false', :record_status_id => rsid)
    authmethod.save(validate: false)

    puts '   - Admin user'
    #Create first user
    user = User.new(:first_name => 'Administrator', :last_name => 'Estimancy', :login_name => 'admin', :initials => 'ad', :email => 'youremail@yourcompany.net', :auth_type => AuthMethod.first.id, :user_status => 'active', :language_id => Language.first.id, :time_zone => 'GMT')
    user.password = user.password_confirmation = 'projestimate'
    user.save
    
    puts '   - Default groups'
    #Create default groups
    Group.create(:name => 'MasterAdmin', :record_status_id => rsid)
    Group.create(:name => 'Admin', :record_status_id => rsid)
    Group.create(:name => 'Everyone', :record_status_id => rsid)
    #Associated default user with group MasterAdmin
    user.group_ids = [Group.first.id]
    user.save

    puts '   - Labor categories'
    #Default labor category
      array_labor_category = Array.new
      array_labor_category = [
        ['Director', 'TBD'],
        ['Manager', 'TBD'],
        ['Program Manager', 'TBD'],
        ['Administrator', 'TBD'],
        ['Project Manager', 'TBD'],
        ['Team leader', 'TBD'],
        ['Consultant', 'TBD'],
        ['Analyst', 'TBD'],
        ['System Analyst', 'TBD'],
        ['Architect', 'TBD'],
        ['Computer Programmer', 'TBD'],
        ['Trainer', 'TBD'],
        ['Technician', 'TBD'],
        ['Operator', 'TBD'],
        ['Support Agent', 'TBD'],
        ['Document writer', 'TBD'],
        ['Test Agent', 'TBD']
      ]

      array_labor_category.each do |i|
        LaborCategory.create(:name => i[0], :description => i[1], :record_status_id => rsid)
      end
      #laborcategory=LaborCategory.first
    
  puts ' Creating organizations...'
    Organization.create(:name => 'YourOrganization', :description => 'This must be update to match your organization')
    organization = Organization.first
    Organization.create(:name => 'Other', :description => 'This could be used to group users that are not members of any organization')

    #puts "   - Inflation"
    #Inflation.create(:organization_id => organization.id, :year => Time.now.strftime("%Y"), :labor_inflation => "1.0", :material_inflation => "1.0", :description => "TBD" )
    
    #puts "   - Organization Labor Category"
    #OrganizationLaborCategory.create(:labor_category_id => laborcategory, :organization_id => organisation, :name=laborcategory.name)    
    
  puts ' Creating Samples data ...'

    puts '   - Demo project'
    #Create default project
    Project.create(:title => 'Sample project', :description => 'This is a sample project for demonstration purpose', :alias => 'sample project', :state => 'preliminary', :start_date => Time.now.strftime('%Y/%m/%d'), :is_model => false, :organization_id => organization.id, :project_area_id => pjarea.id, :project_category_id => ProjectCategory.first.id, :platform_category_id => PlatformCategory.first.id, :acquisition_category_id =>  AcquisitionCategory.first.id)
    project = Project.first
    #Associated default user with sample project     
    user.project_ids = [project.id]
    user.save
    #Create default Pe-wbs-Project associated with previous project
    PeWbsProject.create(:project_id => project.id, :name => "#{project.title} PBS-Product", :wbs_type => 'Product')
    pe_wbs_project = PeWbsProject.first
    #Create root pbs_project_element
    PbsProjectElement.create(:is_root => true, :pe_wbs_project_id => pe_wbs_project.id, :work_element_type_id => wet.id, :position => 0, :name => 'Root folder')
    #pbs_project_element = PbsProjectElement.first
    PeWbsProject.create(:project_id => project.id, :name => "#{project.title} WBS-Activity", :wbs_type => 'Activity')
    pe_wbs_project = PeWbsProject.last
    #Create root pbs_project_element
    WbsProjectElement.create(:is_root => true, :pe_wbs_project_id => pe_wbs_project.id, :description => 'WBS-Activity Root Element', :name => "Root Element - #{project.title} WBS-Activity)")
    #wbs_project_element = wbsProjectElement.first
  #create the initialization project module
  unless initialization_module.nil?
    cap_module_project = project.module_projects.build(:pemodule_id => initialization_module.id, :position_x => 0, :position_y => 0)
    if cap_module_project.save
      #Create the corresponding EstimationValues
      unless project.organization.nil? || project.organization.attribute_organizations.nil?
        project.organization.attribute_organizations.each do |am|
          ['input', 'output'].each do |in_out|
            mpa = EstimationValue.create(:pe_attribute_id => am.pe_attribute.id,
                                         :module_project_id => cap_module_project.id,
                                         :in_out => in_out,
                                         :is_mandatory => am.is_mandatory,
                                         :description => am.pe_attribute.description,
                                         :display_order => nil,
                                         :string_data_low => {:pe_attribute_name => am.pe_attribute.name, :default_low => ''},
                                         :string_data_most_likely => {:pe_attribute_name => am.pe_attribute.name, :default_most_likely => ''},
                                         :string_data_high => {:pe_attribute_name => am.pe_attribute.name, :default_high => ''})
          end
        end
      end
    end
  end

    puts 'Create project security level...'
    #Default project Security Level
    project_security_level = ['FullControl', 'Define', 'Modify', 'Comment', 'ReadOnly']
    project_security_level.each do |i|
      ProjectSecurityLevel.create(:name => i, :record_status_id => rsid)
    end

    puts 'Create global permissions...'
    #Default permissions
    permissions= [ ['edit_own_profile', 'Edit your own profile', false],
                   ['validate_user_account', 'Validate user accounts', false],
                   ['edit_user_account_no_admin', 'Editing user accounts (except Admin and MasterAdmin accounts)', false],
                   ['edit_account_super_admin', 'Editing Admin and MasterAdmin accounts', false],
                   ['edit_account_admin', 'Editing Admin accounts (but not MasterAdmin accounts)', false],
                   ['edit_groups', 'Editing groups', false],
                   ['manage_permissions', 'Manage (all) permissions', true],
                   ['manage_specific_permissions', 'Manage project permissions', false],
                   ['manage_project_area', 'Manage Project Area', false],
                   ['manage_currency', 'Manage Currency', false],
                   ['manage_organizations', 'Manage Organizations', false],
                   ['manage_labor_categories', 'Manage Labor Categories', false],
                   ['manage_event_types', 'Manage Event types', true],
                   ['manage_project_categories', 'Manage Project Categories', false],
                   ['manage_platform_categories', 'Manage Platform Categories', false],
                   ['manage_acquisition_categories', 'Manage Acquisition Categories', false],
                   ['manage_wet', 'Manage Work Element Types', false],
                   ['manage_attributes', 'Manage Attributes', false],
                   ['manage_modules', 'Manage Modules', false],
                   ['manage_activity_categories', 'Manage Activity Categories', false],
                   ['manage_help_messages', 'Manage Help message', false],
                   ['edit_languages', 'Manage languages of the application', false],
                   ['access_to_admin', 'Access to administration page', false],
                   ['create_new_project', 'Create new project', false],
                   ['delete_a_project', 'Delete project', true],
                   ['edit_a_project', 'Edit project', true],
                   ['access_to_a_project', 'Access to project', true],
                   ['list_project', 'View the list of Project (project index)', true],
                   ['add_a_pbs_project_element', 'Add a PbsProjectElement', true],
                   ['delete_a_pbs_project_element', 'Delete PbsProjectElement', true],
                   ['move_a_pbs_project_element', 'Move PbsProjectElement', true],
                   ['edit_a_pbs_project_element', 'Edit PbsProjectElement', true],
                   ['access_to_a_pbs_project_element', 'Access PbsProjectElement', true],
                   ['add_a_module_to_a_process', 'Add Module to project estimation process', true],
                   ['delete_a_module_project', 'Delete a project module', true],
                   ['move_a_module_project', 'Move a project module', true],
                   ['edit_a_module_project', 'Edit a project module', true],
                   ['run_estimation_process', 'Run an estimation process', true],
                   ['access_to_a_module', 'Access Modules', true],
                   ['add_an_attribute', 'Add attribute', true],
                   ['delete_an_attribute', 'Delete Attribute', true],
                   ['edit_an_attribute', 'Edit Attribute', true],
                   ['access_to_attributes', 'Access to Attributes', true],
                   ['edit_own_profile_security', 'Edit profile security', false]
                  ]

    permissions.each do |i|
      Permission.create(:name => String.keep_clean_space(i[0]), :description => i[1], :is_permission_project => i[2], :record_status_id => rsid)
    end

  #  puts "\n\n"
  #  puts "Default data was successfully loaded. Enjoy !"
  #rescue Errno::ECONNREFUSED
  #  puts "\n\n\n"
  #  puts "!!! WARNING - Error: Default data was not loaded, please investigate"
  #  puts "Maybe run bundle exec rake sunspot:solr:start RAILS_ENV=your_environnement"
  #rescue Exception
  #  puts "\n\n"
  #  puts "!!! WARNING - Exception: Default data was not loaded, please investigate"
  #  puts "Maybe run db:create and db:migrate tasks."
  #end
end


def are_you_sure?(&block)
  j = true
  while j do
    puts 'Are you sure do you continue (Y or N) ? : '
    STDOUT.flush
    res = STDIN.gets.chomp!
    if res == 'Y' or res == 'y'
      block.call
      j = false
    elsif res == 'N' or res == 'n'
      puts 'Nothing to do. Bye.'
      j = false
    else
      puts 'Incorrect answer'
      j = true
    end
  end
end