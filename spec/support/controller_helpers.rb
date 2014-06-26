
module ControllerHelpers

  def sign_in(user = "user")
    if user.nil?
      request.env['warden'].stub(:authenticate!).and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user) { nil }
    else
      request.env["devise.mapping"] = Devise.mappings[:user]
      master_group = FactoryGirl.create(:master_admin_group)
      user = FactoryGirl.create(:user, :groups => [master_group])

      request.env['warden'].stub :authenticate! => user
      allow(controller).to receive(:current_user) { user }
    end
  end

  #def sign_in(user = double('user'))
  #def sign_in(user = User.first)
  def sign_in_save(user = "user")
    if user.nil?
      request.env['warden'].stub(:authenticate!).
          and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user) { nil }
    else
      #master_group = FactoryGirl.create(:group)
      #defined_group = FactoryGirl.create(:defined_group)
      #master_group = FactoryGirl.create(:master_admin_group)
      #admin_group = FactoryGirl.create(:admin_group)
      #everyone_group = FactoryGirl.create(:everyone_group)
      #user = FactoryGirl.build(:user, :groups => [master_group])
      #user.confirm!

      request.env['warden'].stub :authenticate! => user
      allow(controller).to receive(:current_user) { user }
    end
  end

end



