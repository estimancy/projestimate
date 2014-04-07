# -*- coding: utf-8 -*-
require 'time_diff'

namespace :projestimate do
  desc "Task that purges the Audit data from server side"

  task :purge_audit_history_data => :environment do
    begin
      @defined_record_status = RecordStatus.find_by_name('Defined')
      # get the admin parameter
      audit_history_setting = AdminSetting.find_by_key_and_record_status_id('audit_history_lifetime', @defined_record_status.id)
      if audit_history_setting && audit_history_setting != 0
        audit_history_setting_value = audit_history_setting.value
        time_unit = audit_history_setting_value.split(' ').last

        I18n.t("datetime.distance_in_words.x_#{setting_value.last.to_s.pluralize}", :count => value.to_i)

        # get all audit history data that feet the conditions: to be deleted
        audit_histories = Audit.where('(Time.now - created_at) >= ?', )



        time_difference = Time.diff(Time.parse("#{start_date_time}"), Time.now)

      end
    rescue Exception => e
      puts "Error : #{e.message}"
      puts e.message
    end
  end
end
