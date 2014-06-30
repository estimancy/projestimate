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

require 'open-uri'
require 'mysql2'

class Home < ActiveRecord::Base
  attr_accessible
  include ExternalMasterDatabase

  EXTERNAL_BASES = [ExternalWbsActivityElement, ExternalWbsActivity, ExternalLanguage, ExternalPeAttribute, ExternalProjectArea, ExternalProjectCategory, ExternalPlatformCategory,
                    ExternalAcquisitionCategory, ExternalPeicon, ExternalWorkElementType, ExternalCurrency, ExternalAdminSetting, ExternalAuthMethod, ExternalGroup, ExternalLaborCategory, ExternalProjectSecurityLevel,
                    ExternalPermission, ExternalSizeUnit]
  def self.connect_external_database
    #begin
      db = Mysql2::Client.new(ExternalMasterDatabase::HOST)
        return db
    #rescue Mysql2::Error
    #  puts 'We could not connect to our database;'
    #  exit 1
    #end
  end

  def self.update_master_data!
    db=Home::connect_external_database
    puts 'Updating from Master Data...'

    #begin

    #Get the external and local record_status ID
    ext_defined_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    local_defined_rs_id = RecordStatus.find_by_name('Defined').id

    puts '   - Estimancy Module'
    self.update_records(ExternalMasterDatabase::ExternalPemodule, Pemodule, ['title', 'alias', 'description', 'compliant_component_type', 'with_activities', 'uuid'])

    puts '   - Attribute...'
    self.update_records(ExternalMasterDatabase::ExternalPeAttribute, PeAttribute, ['name', 'alias', 'description', 'attr_type', 'aggregation', 'options', 'uuid', 'precision', 'single_entry_attribute'])

    puts '   - Attribute Module'
    self.update_records(ExternalMasterDatabase::ExternalAttributeModule, AttributeModule, ['description', 'default_low', 'default_most_likely', 'default_high', 'in_out', 'is_mandatory', 'uuid'])

    #Associate attribute modules to modules
    ext_pemodules = ExternalPemodule.all
    ext_attr_modules = ExternalAttributeModule.all
    ext_pemodules.each do |ext_module|
      ext_attr_modules.each do |ext_attr_module|
        if ext_module.id == ext_attr_module.pemodule_id and ext_module.record_status_id == ext_defined_rs_id
          loc_module = Pemodule.find_by_uuid(ext_module.uuid)
          ext_attr = ExternalMasterDatabase::ExternalPeAttribute.find_by_id(ext_attr_module.pe_attribute_id)
          loc_attr = PeAttribute.find_by_uuid(ext_attr.uuid)
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET pemodule_id = #{loc_module.id} WHERE uuid = '#{ext_attr_module.uuid}'")
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET pe_attribute_id = #{loc_attr.id} WHERE uuid = '#{ext_attr_module.uuid}'")
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET record_status_id = #{local_defined_rs_id} WHERE uuid = '#{ext_attr_module.uuid}'")
        end
      end
    end

    puts '   - WBS Activity'
    self.update_records(ExternalMasterDatabase::ExternalWbsActivity, WbsActivity, ['name', 'description', 'uuid', 'state'])

    puts '   - WBS Activity Elements'
    self.update_records(ExternalMasterDatabase::ExternalWbsActivityElement, WbsActivityElement, ['name', 'description', 'dotted_id', 'uuid', 'is_root'])

    puts '   - Wbs Activity Ratio'
    self.update_records(ExternalMasterDatabase::ExternalWbsActivityRatio, WbsActivityRatio, ['name', 'description', 'uuid'])

    puts '   - Wbs Activity Ratio Elements'
    self.update_records(ExternalMasterDatabase::ExternalWbsActivityRatioElement, WbsActivityRatioElement, ['ratio_value', 'simple_reference', 'multiple_references', 'uuid'])

    puts '   - Project areas'
    self.update_records(ExternalMasterDatabase::ExternalProjectArea, ProjectArea, ['name', 'description', 'uuid'])

    puts '   - Project categories'
    self.update_records(ExternalMasterDatabase::ExternalProjectCategory, ProjectCategory, ['name', 'description', 'uuid'])

    puts '   - Platform categories'
    self.update_records(ExternalMasterDatabase::ExternalPlatformCategory, PlatformCategory, ['name', 'description', 'uuid'])

    puts '   - Acquisition categories'
    self.update_records(ExternalMasterDatabase::ExternalAcquisitionCategory, AcquisitionCategory, ['name', 'description', 'uuid'])

    puts '   - Attribute Category'
    self.update_records(ExternalMasterDatabase::ExternalAttributeCategory, AttributeCategory, ['name', 'alias','uuid'])

    puts '   - Factor'
    self.update_records(ExternalMasterDatabase::ExternalFactor, Factor, ['name', 'alias', 'description', 'factor_type', 'uuid'])

    puts '   - Complexity...'
    self.update_records(ExternalMasterDatabase::ExternalOrganizationUowComplexity, OrganizationUowComplexity, ['name', 'description', 'display_order', 'uuid'])

    puts '   - Technologies...'
    self.update_records(ExternalMasterDatabase::ExternalTechnology, Technology, ['name', 'description', 'uuid'])

    puts '   - Size Unit...'
    self.update_records(ExternalMasterDatabase::ExternalSizeUnit, SizeUnit, ['name', 'alias', 'description', 'uuid'])

    #Associate
    ext_factors = ExternalMasterDatabase::ExternalFactor.all
    ext_complexities = ExternalMasterDatabase::ExternalOrganizationUowComplexity.all
    ext_factors.each do |ext_factor|
      ext_complexities.each do |ext_complexity|
        if ext_factor.id == ext_complexity.factor_id and ext_factor.record_status_id == ext_defined_rs_id
          loc_factor = Factor.find_by_uuid(ext_factor.uuid)
          loc_cplx = OrganizationUowComplexity.where(uuid: ext_complexity.uuid, organization_id: nil).first
          begin
            loc_cplx.factor_id = loc_factor.id
            loc_cplx.display_order = ext_complexity.display_order
            loc_cplx.value = ext_complexity.value
            loc_cplx.save(validate: false)
          rescue
          end
        end
      end
    end

    puts '   - Estimancy Icons'
    #self.update_records(ExternalMasterDatabase::ExternalPeicon, Peicon, ['name', 'icon_file_name', 'icon_content_type', 'icon_updated_at', 'icon_file_size', 'uuid'])
    external_icons = ExternalMasterDatabase::ExternalPeicon.send(:defined, ext_defined_rs_id).send(:all)

    external_icons.each do |ext_icon|
      icon_name = ext_icon.icon_file_name
      icon_url=ext_icon.icon.url
      icon_id=icon_url.split('/')[7]
      #unless Dir.entries("#{Rails.root}/public/").include?(icon_name)
      #  url = "http://forge.estimancy.com:8888/system/peicons/icons/000/000/#{icon_id}/small/#{icon_name}"
      #  File.open("#{Rails.root}/public/#{icon_name}", 'wb') do |saved_file|
      #    # the following "open" is provided by open-uri
      #    open(url, 'rb') do |read_file|
      #      saved_file.write(read_file.read)
      #    end
      #  end
      #end
      #end
      #self.update_records(ExternalMasterDatabase::ExternalPeicon, Peicon, ['name', 'icon_file_name', 'icon_content_type', 'icon_updated_at', 'icon_file_size', 'uuid'])

      peicon=Peicon.find_by_uuid(ext_icon.uuid)
      unless peicon.nil?
        id_icon=peicon.id
        icon = Peicon.find(id_icon)
        icon.update_attributes(:name => ext_icon.name, :icon => File.new("#{Rails.root}/public/#{icon_name}"), :record_status_id => local_defined_rs_id,:uuid=> ext_icon.uuid)
      else
        icon = Peicon.create(:name => ext_icon.name, :icon => File.open("#{Rails.root}/public/#{icon_name}"), :record_status_id => local_defined_rs_id, :uuid => ext_icon.uuid )
        icon.uuid=ext_icon.uuid
        icon.save
      end
    end

    puts '   - WorkElementType'
    self.update_records(ExternalMasterDatabase::ExternalWorkElementType, WorkElementType, ['name', 'alias', 'peicon_id', 'uuid'])
    ext_defined_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    local_defined_rs_id = RecordStatus.find_by_name('Defined').id
    external_icons = ExternalMasterDatabase::ExternalPeicon.send(:defined, ext_defined_rs_id).send(:all)
    external_work_element_type = ExternalMasterDatabase::ExternalWorkElementType.send(:defined, ext_defined_rs_id).send(:all)

    external_work_element_type.each do |ext_work_element_type|
      ext_peicon_id= ext_work_element_type.peicon_id
      rows = db.query("SELECT uuid FROM peicons where id='#{ext_peicon_id}'")
      peicon_uuid=0
      rows.each do |row|
        peicon_uuid=row
      end
      peicon=Peicon.find_by_uuid(peicon_uuid['uuid'])
      unless peicon.nil?
        id_icon=peicon.id
        loc_workElementType = WorkElementType.find_by_uuid(ext_work_element_type.uuid)
        loc_workElementType.update_attributes(:peicon_id => id_icon, :record_status_id => local_defined_rs_id)
      end
    end

    puts '   - Currencies'
    self.update_records(ExternalMasterDatabase::ExternalCurrency, Currency, ['name', 'alias', 'description', 'iso_code', 'iso_code_number', 'sign', 'conversion_rate', 'uuid'])

    puts '   - Language...'
    self.update_records(ExternalMasterDatabase::ExternalLanguage, Language, ['name', 'locale', 'uuid'])

    puts '   - Admin Settings'
    self.update_records(ExternalMasterDatabase::ExternalAdminSetting, AdminSetting, ['key', 'value', 'uuid'])

    puts '   - Auth Method'
    self.update_records(ExternalMasterDatabase::ExternalAuthMethod, AuthMethod, ['name', 'server_name', 'port', 'base_dn', 'uuid'])

    puts '   - Default groups'
    self.update_records(ExternalMasterDatabase::ExternalGroup, Group, ['name', 'description', 'for_global_permission', 'for_project_security', 'uuid'])

    puts '   - Labor categories'
    self.update_records(ExternalMasterDatabase::ExternalLaborCategory, LaborCategory, ['name', 'description', 'uuid'])

    puts '   - Security level'
    self.update_records(ExternalMasterDatabase::ExternalProjectSecurityLevel, ProjectSecurityLevel, ['name', 'description', 'uuid'])

    puts '   - Global permissions'
    self.update_records(ExternalMasterDatabase::ExternalPermission, Permission, ['name', 'description', 'object_associated', 'is_permission_project', 'uuid','alias','is_master_permission','category'])

    #Update the latest update date information
    latest_saved_record = Version.last
    latest_repo_update = Home::latest_repo_update
    latest_saved_record.update_attributes(:local_latest_update => Time.now, :repository_latest_update => latest_repo_update, :comment => 'Your Application latest update date')

    #  puts "\n\n"
    #  puts "Default data was successfully loaded. Enjoy !"
    #rescue Errno::ECONNREFUSED
    #  puts "\n\n\n"
    #  puts "!!! WARNING - Error: Default data was not loaded, please investigate"
    #  puts "Maybe run bundle exec rake sunspot:solr:start RAILS_ENV=your_environment"
    #rescue Exception
    #  puts "\n\n"
    #  puts "!!! WARNING - Exception: Default data was not loaded, please investigate"
    #  puts "Maybe run db:create and db:migrate tasks."
    #end
  end

  def self.latest_repo_update
    dates = Array.new
    EXTERNAL_BASES.each do |table|
      dates << table.all.map(&:updated_at)
    end
    res = dates.flatten.compact.max
    res
  end

  def self.update_records(external, local, fields)
    loc_defined_rs_id = RecordStatus.find_by_name('Defined').id
    loc_custom_rs_id = RecordStatus.find_by_name('Custom').id
    loc_local_rs_id = RecordStatus.find_by_name('Local').id
    ext_defined_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    ext_custom_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Custom').id
    ext_local_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Local').id

    externals = external.send(:defined, ext_defined_rs_id).send(:all)
    locals = local.send(:all)
    fields = fields + %w(change_comment)

    #We have to consider statuses listed in custom_status_to_consider
    custom_status_to_consider = AdminSetting.find_by_key('custom_status_to_consider')
    unless custom_status_to_consider.blank?
      statuses_to_consider = custom_status_to_consider.value.nil? ? [] : custom_status_to_consider.value.split(';')

      statuses_to_consider.each do |custom_value|
        #For each custom_value_to_consider, we find the corresponding record on Master with the same custom value
        ext_custom_record = external.find_by_record_status_id_and_custom_value(ext_custom_rs_id, custom_value)

        #If there is at least one custom record to consider
        unless ext_custom_record.nil?
          #We need to get the external record parent, then priority is given to the custom one
          ext_custom_record_parent = external.find_by_uuid(ext_custom_record.reference_uuid)

          #If the record has no parent, it will be added in the list to be consider for the update
          if ext_custom_record_parent.nil?
            externals.push(ext_custom_record)
          else
            #Else, the record has its parent (may be already consider for update)
            #In this case, priority is given to  custom one
            new_fields = fields + %w(record_status_id) - %w(uuid)

            externals.map! { |item|
              if item.uuid == ext_custom_record.reference_uuid
                new_fields.each do |field|
                  item.send("#{field}=", ext_custom_record.send(field.to_sym))
                end
                item
              else
                item
              end
            }
          end
        end
      end
    end

    externals.each do |ext|
      corresponding_local_rs_id = nil
      if ext.record_status_id == ext_defined_rs_id
        corresponding_local_rs_id = loc_defined_rs_id
      elsif ext.record_status_id == ext_custom_rs_id
        corresponding_local_rs_id = loc_custom_rs_id
      end

      if locals.map(&:uuid).include?(ext.uuid)
        #We only need to update Defined or Custom record (local and locally edited records will be kept intact)
        local_record = local.corresponding_local_record(ext.uuid, loc_local_rs_id).first

        unless local_record.nil?
          if local.to_s == 'AdminSetting'
            if local_record.custom_value == 'Locally edited'
              fields = fields - ['value']
            end
          end

          fields.each do |field|
            local_record.update_attribute(:"#{field}", ext.send(field.to_sym))
          end

          #For Wbs-Activity-Elements, we need to rebuild the ancestry if it has changed
          if local.to_s == 'WbsActivityElement'
            #Test if the element ancestry changed
            unless ext.ancestry.to_s.eql?(local_record.master_ancestry.to_s)
              local_ancestry = ''
              ext_ancestry = ext.ancestry
              unless ext_ancestry.nil?
                ext_ancestry_list = ext.ancestry.split('/')
                ext_ancestry_list.each do |ancestor|
                  ext_ancestor_uuid = ExternalMasterDatabase::ExternalWbsActivityElement.find_by_id(ancestor).uuid
                  ancestors << WbsActivityElement.find_by_uuid(ext_ancestor_uuid).id
                end
                if ancestors.length == 1
                  local_ancestry = ancestors.first.to_s
                elsif ancestors.length > 1
                  local_ancestry = ancestors.join('/')
                end
              end
              local_record.update_attributes(:ancestry => local_ancestry, :master_ancestry => ext.ancestry)
            end
          end

          local_record.update_attributes(:record_status_id => corresponding_local_rs_id, :change_comment => ext.change_comment)
        end

      else
        obj = local.send(:new)
        #for each fields
        fields.each do |field|
          #we update our local object with the external value
          obj.update_attribute(:"#{field}", ext.send(field.to_sym))
        end

        #Need to update link between Wbs-Activity and its elements
        case local.to_s
          when 'WbsActivityElement'
            ext_wbs_activity_uuid = ExternalMasterDatabase::ExternalWbsActivity.find_by_id(ext.wbs_activity_id).uuid
            corresponding_wbs_activity_id = WbsActivity.find_by_uuid(ext_wbs_activity_uuid).id

            #build ancestry
            local_ancestry = ''
            ActiveRecord::Base.transaction do
              ancestors = []
              ext_ancestry = ext.ancestry
              unless ext_ancestry.nil?
                ext_ancestry_list = ext.ancestry.split('/')
                ext_ancestry_list.each do |ancestor|
                  ext_ancestor_uuid = ExternalMasterDatabase::ExternalWbsActivityElement.find_by_id(ancestor).uuid
                  ancestors << WbsActivityElement.find_by_uuid(ext_ancestor_uuid).id
                end
                if ancestors.length == 1
                  local_ancestry = ancestors.first.to_s
                elsif ancestors.length > 1
                  local_ancestry = ancestors.join('/')
                end
              end
            end
            #obj.update_attributes(:wbs_activity_id => corresponding_wbs_activity_id, :ancestry => local_ancestry.to_s, :master_ancestry => ext.ancestry.to_s)
            ActiveRecord::Base.connection.execute("UPDATE wbs_activity_elements SET wbs_activity_id = #{corresponding_wbs_activity_id}, ancestry = '#{local_ancestry}', master_ancestry = '#{ext.ancestry}' WHERE uuid = '#{ext.uuid}'")
          when 'WbsActivityRatio'
            ext_wbs_activity_uuid = ExternalMasterDatabase::ExternalWbsActivity.find_by_id(ext.wbs_activity_id).uuid
            corresponding_wbs_activity_id = WbsActivity.find_by_uuid(ext_wbs_activity_uuid).id
            obj.update_attribute(:wbs_activity_id, corresponding_wbs_activity_id)

          when 'WbsActivityRatioElement'
            begin
              ext_ratio_uuid = ExternalMasterDatabase::ExternalWbsActivityRatio.find_by_id(ext.wbs_activity_ratio_id).uuid
              ext_wbs_activity_element_uuid = ExternalMasterDatabase::ExternalWbsActivityElement.find_by_id(ext.wbs_activity_element_id).uuid
              local_wbs_activity_ratio_id = WbsActivityRatio.find_by_uuid(ext_ratio_uuid).id
              local_wbs_activity_element_id = WbsActivityElement.find_by_uuid(ext_wbs_activity_element_uuid).id
              obj.update_attributes(:wbs_activity_ratio_id => local_wbs_activity_ratio_id, :wbs_activity_element_id => local_wbs_activity_element_id)
            rescue
            end
        end

        obj.update_attributes(:record_status_id => corresponding_local_rs_id, :change_comment => ext.change_comment)
      end
    end
  end

  #calling create_records(ExternalMasterDatabase::ExternalLanguage, Language, ["name", "description"])
  #ext: external table name
  #loc: locale table name
  #fields: fields concerned
  def self.create_records(external, loc, fields)
    #Find correct record status id
    local_defined_rs_id = RecordStatus.find_by_name('Defined').id
    ext_rsid = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    ext_custom_rsid = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Custom').id

    #get all records (ex : ExternalMasterDatabase::ExternalLanguage.all)
    #puts "Class = #{ExternalMasterDatabase::ExternalPemodule}"
    externals = external.send(:defined, ext_rsid).send(:all)

    #for each external records...
    externals.each do |ext|
      #...a record is instanced in the local table name
      obj = loc.send(:new)
      #for each fields
      fields.each do |field|
        #we update our local object with the external value
        obj.update_attribute(:"#{field}", ext.send(field.to_sym))
      end
      obj.update_attributes(:record_status_id => local_defined_rs_id, :change_comment => ext.change_comment)
    end
  end

  #Load MasterData from scratch
  def self.load_master_data!
    db=Home::connect_external_database
    #begin
    record_status = ExternalMasterDatabase::ExternalRecordStatus.all
    record_status.each do |i|
      rs = RecordStatus.new(:name => i.name, :description => i.description, :uuid => i.uuid)
      rs.save(:validate => false)
      #rs.save
    end

    ext_defined_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    local_defined_rs_id = RecordStatus.find_by_name('Defined').id

    puts '   - Record Status' #Update record status to "Defined"
    record_statuses = RecordStatus.all
    record_statuses.each do |rs|
      rs.update_attribute(:record_status_id, local_defined_rs_id)
    end

    puts '   - Version'
    Version.create :comment => 'No update data has been save'

    puts '   - Estimancy Module'
    self.create_records(ExternalMasterDatabase::ExternalPemodule, Pemodule, ['title', 'alias', 'description', 'compliant_component_type', 'with_activities', 'uuid'])

    puts '   - Attribute...'
    self.create_records(ExternalMasterDatabase::ExternalPeAttribute, PeAttribute, ['name', 'alias', 'description', 'attr_type', 'aggregation', 'options', 'uuid', 'precision', 'single_entry_attribute'])

    puts '   - Attribute Category'
    self.create_records(ExternalMasterDatabase::ExternalAttributeCategory, AttributeCategory, ['name', 'alias','uuid'])

    puts '   - Attribute Module'
    self.create_records(ExternalMasterDatabase::ExternalAttributeModule, AttributeModule, ['description', 'default_low', 'default_most_likely', 'default_high', 'in_out', 'is_mandatory', 'uuid'])

    #Associate attribute modules to modules
    ext_pemodules = ExternalPemodule.all
    ext_attr_modules = ExternalAttributeModule.all
    ext_pemodules.each do |ext_module|
      ext_attr_modules.each do |ext_attr_module|
        if ext_module.id == ext_attr_module.pemodule_id and ext_module.record_status_id == ext_defined_rs_id
          loc_module = Pemodule.find_by_uuid(ext_module.uuid)
          ext_attr = ExternalMasterDatabase::ExternalPeAttribute.find_by_id(ext_attr_module.pe_attribute_id)
          loc_attr = PeAttribute.find_by_uuid(ext_attr.uuid)
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET pemodule_id = #{loc_module.id} WHERE uuid = '#{ext_attr_module.uuid}'")
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET pe_attribute_id = #{loc_attr.id} WHERE uuid = '#{ext_attr_module.uuid}'")
          ActiveRecord::Base.connection.execute("UPDATE attribute_modules SET record_status_id = #{local_defined_rs_id} WHERE uuid = '#{ext_attr_module.uuid}'")
        end
      end
    end

    puts '   - Wbs Activity'
    self.create_records(ExternalMasterDatabase::ExternalWbsActivity, WbsActivity, ['name', 'description', 'uuid', 'state'])

    puts '   - Wbs Activity Element'
    self.create_records(ExternalMasterDatabase::ExternalWbsActivityElement, WbsActivityElement, ['name', 'description', 'dotted_id', 'uuid', 'is_root'])

    puts '   - Wbs Activity Ratio'
    self.create_records(ExternalMasterDatabase::ExternalWbsActivityRatio, WbsActivityRatio, ['name', 'description', 'uuid'])

    puts '   - Wbs Activity Ratio Elements'
    self.create_records(ExternalMasterDatabase::ExternalWbsActivityRatioElement, WbsActivityRatioElement, ['ratio_value', 'simple_reference', 'multiple_references', 'uuid'])

    puts '       - Rebuilding tree in progress...'
    activities = WbsActivity.all
    elements = WbsActivityElement.all
    ext_activities = ExternalMasterDatabase::ExternalWbsActivity.all
    ext_elements = ExternalMasterDatabase::ExternalWbsActivityElement.all
    ext_ratios = ExternalMasterDatabase::ExternalWbsActivityRatio.all
    ext_ratio_elements = ExternalMasterDatabase::ExternalWbsActivityRatioElement.all

    ext_activities.each do |ext_act|
      #Associate activity element to activity
      ext_elements.each do |ext_elt|
        if ext_act.id == ext_elt.wbs_activity_id and ext_act.record_status_id == ext_defined_rs_id
          act = WbsActivity.find_by_uuid(ext_act.uuid)

          #build ancestry
          local_ancestry = ''
          ActiveRecord::Base.transaction do
            ancestors = []
            ext_ancestry = ext_elt.ancestry
            unless ext_ancestry.nil?
              ext_ancestry_list = ext_elt.ancestry.split('/')
              ext_ancestry_list.each do |ancestor|
                ext_ancestor_uuid = ExternalMasterDatabase::ExternalWbsActivityElement.find_by_id(ancestor).uuid
                ancestors << WbsActivityElement.find_by_uuid(ext_ancestor_uuid).id
              end
              if ancestors.length == 1
                local_ancestry = ancestors.first.to_s
              elsif ancestors.length > 1
                local_ancestry = ancestors.join('/')
              end
            end
          end
          ActiveRecord::Base.connection.execute("UPDATE wbs_activity_elements SET wbs_activity_id = #{act.id}, ancestry = '#{local_ancestry}', master_ancestry = '#{ext_elt.ancestry}' WHERE uuid = '#{ext_elt.uuid}'")
        end
      end

      #Associate activity ratio to activity
      ext_ratios.each do |ext_ratio|
        if ext_act.id == ext_ratio.wbs_activity_id and ext_act.record_status_id == ext_defined_rs_id
          act = WbsActivity.find_by_uuid(ext_act.uuid)
          ActiveRecord::Base.connection.execute("UPDATE wbs_activity_ratios SET wbs_activity_id = #{act.id} WHERE uuid = '#{ext_ratio.uuid}'")
        end
      end
    end

    ext_ratios.each do |ext_ratio|
      ext_ratio_elements.each do |ext_ratio_element|
        if ext_ratio.id == ext_ratio_element.wbs_activity_ratio_id and ext_ratio.record_status_id == ext_defined_rs_id
          ratio = WbsActivityRatio.find_by_uuid(ext_ratio.uuid)
          ext_element = ExternalMasterDatabase::ExternalWbsActivityElement.find_by_id(ext_ratio_element.wbs_activity_element_id)
          element = WbsActivityElement.find_by_uuid(ext_element.uuid)
          ActiveRecord::Base.connection.execute("UPDATE wbs_activity_ratio_elements SET wbs_activity_ratio_id = #{ratio.id} WHERE uuid = '#{ext_ratio_element.uuid}'")
          ActiveRecord::Base.connection.execute("UPDATE wbs_activity_ratio_elements SET wbs_activity_element_id = #{element.id} WHERE uuid = '#{ext_ratio_element.uuid}'")
        end
      end
    end

    #activities.each do |a|
    #  WbsActivityElement::build_ancestry(elements, a.id)
    #end

    puts '   - Project areas'
    self.create_records(ExternalMasterDatabase::ExternalProjectArea, ProjectArea, ['name', 'description', 'uuid'])

    pjarea = ProjectArea.first

    puts '   - Project categories'
    self.create_records(ExternalMasterDatabase::ExternalProjectCategory, ProjectCategory, ['name', 'description', 'uuid'])

    puts '   - Platform categories'
    self.create_records(ExternalMasterDatabase::ExternalPlatformCategory, PlatformCategory, ['name', 'description', 'uuid'])

    puts '   - Acquisition categories'
    self.create_records(ExternalMasterDatabase::ExternalAcquisitionCategory, AcquisitionCategory, ['name', 'description', 'uuid'])

    puts '   - Estimancy Icons'
    #Need to have same UUID as Master Instance Icons
    external_icons = ExternalMasterDatabase::ExternalPeicon.send(:defined, ext_defined_rs_id).send(:all)

    #external_icons.each do |ext_icon|
    #    icon_name = ext_icon.icon_file_name
    #    icon_url=ext_icon.icon.url
    #    icon_id=icon_url.split('/')[7]
    #    url = "http://forge.estimancy.com:8888/system/peicons/icons/000/000/#{icon_id}/small/#{icon_name}"
    #    File.open("#{Rails.root}/public/#{icon_name}", 'wb') do |saved_file|
    #      # the following "open" is provided by open-uri
    #      open(url, 'rb') do |read_file|
    #        saved_file.write(read_file.read)
    #      end
    #    end
    #    icon = Peicon.create(:name => ext_icon.name, :icon => File.new("#{Rails.root}/public/#{icon_name}"), :record_status_id => local_defined_rs_id)
    #    icon.update_attribute(:uuid, ext_icon.uuid)
    #end

    puts '   - WBS structure'
    self.create_records(ExternalMasterDatabase::ExternalWorkElementType, WorkElementType, ['name', 'alias', 'peicon_id', 'uuid'])

    wet = WorkElementType.first

    ext_defined_rs_id = ExternalMasterDatabase::ExternalRecordStatus.find_by_name('Defined').id
    local_defined_rs_id = RecordStatus.find_by_name('Defined').id
    external_icons = ExternalMasterDatabase::ExternalPeicon.send(:defined, ext_defined_rs_id).send(:all)
    external_work_element_type = ExternalMasterDatabase::ExternalWorkElementType.send(:defined, ext_defined_rs_id).send(:all)

    external_work_element_type.each do |ext_work_element_type|
      ext_peicon_id= ext_work_element_type.peicon_id
      rows = db.query("SELECT uuid FROM peicons where id='#{ext_peicon_id}'")
      peicon_uuid=0
      rows.each do |row|
        peicon_uuid=row
      end
      peicon=Peicon.find_by_uuid(peicon_uuid['uuid'])
      unless peicon.nil?
        id_icon=peicon.id
        loc_workElementType = WorkElementType.find_by_uuid(ext_work_element_type.uuid)
        loc_workElementType.update_attributes(:peicon_id => id_icon, :record_status_id => local_defined_rs_id)
      end
    end

    puts '   - Currencies'
    self.create_records(ExternalMasterDatabase::ExternalCurrency, Currency, ['name', 'alias', 'description', 'iso_code', 'iso_code_number', 'sign', 'conversion_rate', 'uuid'])

    puts '   - Language...'
    self.create_records(ExternalMasterDatabase::ExternalLanguage, Language, ['name', 'locale', 'uuid'])

    puts '   - Admin Settings'
    self.create_records(ExternalMasterDatabase::ExternalAdminSetting, AdminSetting, ['key', 'value', 'uuid'])

    puts '   - Auth Method'
    self.create_records(ExternalMasterDatabase::ExternalAuthMethod, AuthMethod, ['name', 'server_name', 'port', 'base_dn', 'uuid'])

    puts '   - Factors...'
    self.create_records(ExternalMasterDatabase::ExternalFactor, Factor, ['name', 'alias', 'description', 'state', 'factor_type', 'uuid'])

    puts '   - Complexity levels...'
    self.create_records(ExternalMasterDatabase::ExternalOrganizationUowComplexity, OrganizationUowComplexity, ['name', 'description', 'display_order', 'uuid'])

    puts '   - Technologies...'
    self.create_records(ExternalMasterDatabase::ExternalTechnology, Technology, ['name', 'description', 'uuid'])

    puts '   - Size Unit...'
    self.create_records(ExternalMasterDatabase::ExternalSizeUnit, SizeUnit, ['name', 'alias', 'description', 'uuid'])

    ext_factors = ExternalMasterDatabase::ExternalFactor.all
    ext_complexities = ExternalMasterDatabase::ExternalOrganizationUowComplexity.where(organization_id: nil).all

    ext_factors.each do |ext_factor|

      @loc_factor = Factor.find_by_uuid(ext_factor.uuid)

      ext_complexities.each do |ext_complexity|
        if ext_factor.id == ext_complexity.factor_id and ext_factor.record_status_id == ext_defined_rs_id
          loc_cplx = OrganizationUowComplexity.new(uuid: ext_complexity.uuid)

          loc_cplx.factor_id = @loc_factor.id
          loc_cplx.name = ext_complexity.name
          loc_cplx.description = ext_complexity.description
          loc_cplx.value = ext_complexity.value
          loc_cplx.display_order = ext_complexity.display_order
          loc_cplx.record_status_id = local_defined_rs_id
          loc_cplx.change_comment = ext_complexity.change_comment
          loc_cplx.save

        end
      end
    end

    puts '   - Admin user'
    #Create first user
    user = User.new(:first_name => 'Administrator', :last_name => 'Estimancy', :login_name => 'admin', :initials => 'ad', :email => 'youremail@yourcompany.net', :auth_type => AuthMethod.first.id, :user_status => 'active', :language_id => Language.first.id, :time_zone => 'GMT')
    user.password = user.password_confirmation = 'projestimate'
    user.confirm!
    user.save(:validate => false)

    puts '   - Default groups'
    #Create default groups
    self.create_records(ExternalMasterDatabase::ExternalGroup, Group, ['name', 'description', 'for_global_permission', 'for_project_security', 'uuid'])

    #Associated default user with group first group (Admin)
    master_admin_group = Group.where('name = ? AND record_status_id = ?', 'MasterAdmin', local_defined_rs_id).first
    user.group_ids = [Group.first.id, master_admin_group.id]
    user.save

    puts '   - Labor categories'
    self.create_records(ExternalMasterDatabase::ExternalLaborCategory, LaborCategory, ['name', 'description', 'uuid'])
    laborcategory=LaborCategory.first

    puts '   - Organizations'
    Organization.create(name: 'YourOrganization',
                        description: 'This must be update to match your organization',
                        number_hours_per_day: 8,
                        number_hours_per_month: 160 ,
                        cost_per_hour: 40,
                        currency_id: Currency.first.id,
                        inflation_rate: 1)
    Organization.create(name: 'Other',
                        description: 'This could be used to group users that are not members of any organization',
                        number_hours_per_day: 8,
                        number_hours_per_month: 160 ,
                        cost_per_hour: 40,
                        currency_id: Currency.first.id,
                        inflation_rate: 1)

    organization = Organization.first

    Organization.all.each do |organization|

      OrganizationUowComplexity.where(organization_id: nil).each do |o|
        ouc = OrganizationUowComplexity.new(name: o.name ,
                                            organization_id: organization.id,
                                            description: o.description,
                                            value: o.value,
                                            factor_id: o.factor_id,
                                            is_default: o.is_default,
                                            state: 'defined')
        ouc.save(validate: false)
      end

      Technology.all.each do |technology|
        ot = OrganizationTechnology.create(name: technology.name,
                                           alias: technology.name,
                                           description: technology.description,
                                           organization_id: organization.id)
      end

      s1 = SizeUnitType.create(name: "New", alias: "new", description: "New lines of codes or functions points", organization_id: organization.id )
      SizeUnit.all.each do |su|
        s1.organization.organization_technologies.each do |ot|
          TechnologySizeType.create(organization_id: s1.organization_id,
                                    organization_technology_id: ot.id,
                                    size_unit_id: su.id,
                                    size_unit_type_id: s1.id,
                                    value: 1)
        end
      end

      s2 = SizeUnitType.create(name: "Modified", alias: "modified", description: "Modified lines of codes or functions points", organization_id: organization.id )
      SizeUnit.all.each do |su|
        s2.organization.organization_technologies.each do |ot|
          TechnologySizeType.create(organization_id: s2.organization_id,
                                    organization_technology_id: ot.id,
                                    size_unit_id: su.id,
                                    size_unit_type_id: s2.id,
                                    value: 1)
        end
      end

      s3 = SizeUnitType.create(name: "Reused", alias: "reused", description: "Reused lines of codes or functions points", organization_id: organization.id )
      SizeUnit.all.each do |su|
        s3.organization.organization_technologies.each do |ot|
          TechnologySizeType.create(organization_id: s3.organization_id,
                                    organization_technology_id: ot.id,
                                    size_unit_id: su.id,
                                    size_unit_type_id: s3.id,
                                    value: 1)
        end
      end

    end

    puts '   - Demo project'
    #Create default project
    Project.create(:title => 'Sample project',
                   :description => 'This is a sample project for demonstration purpose',
                   :alias => 'sample project',
                   :state => 'preliminary',
                   :start_date => Time.now.strftime('%Y/%m/%d'),
                   :is_model => false,
                   :organization_id => organization.id,
                   :project_area_id => pjarea.id,
                   :project_category_id => ProjectCategory.first.id,
                   :platform_category_id => PlatformCategory.first.id,
                   :acquisition_category_id => AcquisitionCategory.first.id)

    project = Project.first

    initialization = Pemodule.find_by_alias('initialization')
    ModuleProject.create(:pemodule_id => initialization.id, :project_id => project.id, :position_x => 0, :position_y => 0)

    #New default Pe-Wbs-Project
    pe_wbs_project_product = project.pe_wbs_projects.build(:name => "#{project.title} WBS-Product", :wbs_type => 'Product')
    pe_wbs_project_activity = project.pe_wbs_projects.build(:name => "#{project.title} WBS-Activity", :wbs_type => 'Activity')

    folder = WorkElementType.find_by_alias('folder')

    if pe_wbs_project_product.save
      ##New root Pbs-Project-Element
      pbs_project_element = pe_wbs_project_product.pbs_project_elements.build(:name => "#{project.title} - WBS-Product", :is_root => true, :work_element_type_id => folder.id, :position => 0)
      pbs_project_element.save
      pe_wbs_project_product.save
    end

    if pe_wbs_project_activity.save
      ##New Root Wbs-Project-Element
      wbs_project_element = pe_wbs_project_activity.wbs_project_elements.build(:name => "#{project.title} - WBS-Activity", :is_root => true, :description => 'WBS-Activity Root Element', :author_id => user.id)
      wbs_project_element.save
    end

    #Associated default user with sample project
    user.project_ids = [Project.first.id]
    user.save


    puts '   - Create global permissions...'
    self.create_records(ExternalMasterDatabase::ExternalPermission, Permission, ['name', 'description', 'object_associated', 'is_permission_project', 'uuid','alias','is_master_permission','category'])
    #Associate permissions to groups
    ext_permissions = ExternalMasterDatabase::ExternalPermission.all
    ext_groups = ExternalMasterDatabase::ExternalGroup.all


    #Select groups_permissions table on master database
    rows = db.query('SELECT * FROM groups_permissions')
    groups_permissions=Array.new
    rows.each do |row|
      groups_permissions.push(row)
    end

    ext_records_permission=Array.new
    groups_permissions.each do |record_groups_permissions|
      ext_records_permission.push([record_groups_permissions['permission_id'],record_groups_permissions['group_id']])
    end

    begin
      #Create a table match between master groups_permissions and local groups_permission
      loc_records_permissions=Array.new
      ext_records_permission.each do |record|
        ext_permission_uuid=Array.new
        ext_group_uuid=Array.new
        ext_permission= db.query("SELECT uuid FROM permissions where id=#{record[0]}")
        ext_permission.each do |row|
          ext_permission_uuid = row
        end
        ext_group=db.query("SELECT uuid FROM groups where id=#{record[1]}")
        ext_group.each do |row|
          ext_group_uuid = row
        end

        loc_permission_id = Permission.find_by_uuid(ext_permission_uuid['uuid']).id
        loc_group= Group.find_by_uuid(ext_group_uuid['uuid']).id
        loc_records_permissions << [loc_permission_id,loc_group]
      end
    rescue => e
      puts e.message
      puts e.backtrace.inspect
    end

    #Insert on local database groups_permissions records
    loc_records_permissions.each do |groups_permissions|
      loc_permission = Permission.find(groups_permissions[0])
      loc_group= Group.find(groups_permissions[1])
      loc_permission.groups << loc_group
      loc_permission.save
    end

    puts '   - Create project security level...'
    self.create_records(ExternalMasterDatabase::ExternalProjectSecurityLevel, ProjectSecurityLevel, ['name', 'description', 'uuid'])
    ext_permissions = ExternalMasterDatabase::ExternalPermission.all
    ext_securities_level = ExternalMasterDatabase::ExternalProjectSecurityLevel.all
    # Connect to the master database

    #Select permissions_project_security_levels table on master database
    rows = db.query('SELECT * FROM permissions_project_security_levels')
    permissions_project_security_level=Array.new
    rows.each do |row|
      permissions_project_security_level.push(row)
    end

    ext_records_permission_project=Array.new
    permissions_project_security_level.each do |record_permissions_project_security_level|
      ext_records_permission_project.push([record_permissions_project_security_level['permission_id'],record_permissions_project_security_level['project_security_level_id']])
    end
    #
    ##Create a table match between master permissions_project_security_levels and local permissions_project_security_levels
    loc_records_permissions_project=Array.new
    ext_records_permission_project.each do |record|
      ext_permission_uuid=Array.new
      ext_project_security_level_uuid=Array.new
      ext_permission= db.query("SELECT uuid FROM permissions where id=#{record[0]}")
      ext_permission.each do |row|
        ext_permission_uuid=row
      end
      ext_project_security_levels=db.query("SELECT uuid FROM project_security_levels where id=#{record[1]}")
      ext_project_security_levels.each do |row|
        ext_project_security_level_uuid=row
      end
      loc_permission_id=Permission.find_by_uuid(ext_permission_uuid['uuid']).id

      loc_project_security_level_id= ProjectSecurityLevel.find_by_uuid(ext_project_security_level_uuid['uuid']).id
      loc_records_permissions_project << [loc_permission_id,loc_project_security_level_id]
    end
    #Insert on local database permissions_project_security_levels records
    loc_records_permissions_project.each do |project_security_permissions|
      loc_permission = Permission.find(project_security_permissions[0])
      loc_security_level= ProjectSecurityLevel.find(project_security_permissions[1])
      loc_permission.project_security_levels << loc_security_level
      loc_permission.save
    end


    puts "\n\n"
    puts '   - Default data was successfully loaded. Enjoy !'
    #rescue Errno::ECONNREFUSED
    #  puts "\n\n\n"
    #  puts "!!! WARNING - Error: Default data was not loaded, please investigate."
    #  puts "Maybe run bundle exec rake sunspot:solr:start RAILS_ENV=your_environment."
    #rescue Exception
    #  puts "\n\n"
    #  puts "!!! WARNING - Exception: Default data was not loaded, please investigate..."
    #  puts "Maybe run db:create and db:migrate tasks."
    #end
  end

  #Function to debug ruby scripts
  #uncomment ' match 'homes/testme' => 'homes#testme', :as => 'testme'' in root.rb
  #function testme in home_controller.rb
  #Add link <%= link_to "testeMe", "/homes/testme" %> in projects/index.erb
  #def self.testons
  #
  #end
end
