# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def new
    super
  end

  def create
    super do |resource|
      resource.initials = "your_initials"
      auth_type = AuthMethod.find_by_name('Application')
      @defined_record_status = RecordStatus.find_by_name('Defined')
      everyone_group = Group.find_by_name_and_record_status_id("Everyone", @defined_record_status)
      # Add default Authentication method and group to user
      resource.auth_type = auth_type.nil? ? nil : auth_type.id
      resource.groups << everyone_group
      is_an_automatic_account_activation? ? status = 'active' : status = 'pending'

      resource.user_status = status
      resource.save
    end
  end

  def update
    super
  end

  private

  def is_an_automatic_account_activation?
    #No authorize required since this method is protected and won't be call from any route
    begin
      AdminSetting.where(:record_status_id => RecordStatus.find_by_name('Defined').id, :key => 'self-registration').first.value == 'automatic account activation'
    rescue
      false
    end
  end

end