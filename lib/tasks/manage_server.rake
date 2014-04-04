# -*- coding: utf-8 -*-
require 'time_diff'

namespace :projestimate do
  desc "Task that purges the Audit data from server side"

  task :purge_audit_history_data => :environment do
    begin
      @defined_record_status = RecordStatus.find_by_name('Defined')
      # get the admin parameter
      audit_history_setting = AdminSetting.find_by_key_and_record_status_id('audit_history_lifetime', @defined_record_status.id)
      if  audit_history_setting != 0 && audit_history_setting != I18n.t(:label_disabled)

        # get all audit history data that feet the conditions
        time_difference = TimeDifference.between(start_time, end_time).in_years
        time_diff = Time.diff(start_date_time, end_date_time)

        audit_histories = Audit.where('')
      end
    rescue Exception => e
      puts "Error : #{e.message}"
      puts e.message
    end
  end
end
