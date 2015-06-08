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


module ExternalInclude

  def self.included(base)

    base.class_eval do
      unless base.to_s == 'ExternalInclude:Module'
        has_one :child_reference, :class_name => "#{base}", :inverse_of => :parent_reference, :foreign_key => 'reference_id'
        belongs_to :parent_reference, :class_name => "#{base}", :inverse_of => :child_reference, :foreign_key => 'reference_id'

        current_table_name = base.to_s
        current_table_name1 = current_table_name.gsub!('ExternalMasterDatabase::', '')
        current_table_name2 = current_table_name1.gsub!('External', '')
        base.table_name = current_table_name2.tableize
        scope :defined, lambda { |de| where('record_status_id = ?', de) } #scope :custom_defined, lambda {|de, cu| where("record_status_id = ? or record_status_id = ?", de, cu) }

      end
    end

  end
end


module ExternalMasterDatabase

  HOST = {
      :adapter => 'mysql2',
      :database => 'projestimate_dev',
      :reconnect => false,
      :host => 'dev.estimancy.com',
      :port => 3306,
      :username => 'master',
      :password => 'masterdata',
      :encoding => 'utf8'
  }

  class ExternalWbsActivityRatioElement < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalWbsActivityRatio < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalWbsActivity < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalWbsActivityElement < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalSchemaMigration < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    self.table_name = 'schema_migrations'
  end

  class ExternalAcquisitionCategory < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalPeAttribute < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
    serialize :options, Array
  end

  class ExternalAttributeModule < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalCurrency < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalTechnology < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalSizeUnit < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalEventType < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalLanguage < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalPemodule < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalPlatformCategory < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalProjectArea < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalProjectCategory < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalProjectSecurityLevel < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalRecordStatus < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalWorkElementType < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalAdminSetting < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalAuthMethod < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalFactor < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalOrganizationUowComplexity < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end

  class ExternalGroup < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
    has_and_belongs_to_many :permissions
  end

  class ExternalPermission < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
    has_and_belongs_to_many :groups
  end

  class ExternalRecordStatus < ActiveRecord::Base
    attr_accessible
    establish_connection HOST
    include ExternalInclude
  end
end