# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# This task is planned to delete all history data according the the "audit_history_lifetime" parameter

# The projestimate crontab name is "projestimate_cron_job"
# Updating crontab with the following command : << whenever --update-crontab projestimate_cron_job >>

every 1.day, :at => '4am' do
  rake "projestimate:purge_audit_history_data"
end


# Only for local test
#every 5.minutes do
#  rake "projestimate:purge_audit_history_data"
#end


# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
