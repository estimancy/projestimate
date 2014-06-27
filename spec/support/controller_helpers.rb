
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

  def sign_in_SAVE(user = double('user'))
    if user.nil?
      request.env['warden'].stub(:authenticate!).
          and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user) { nil }
    else
      request.env['warden'].stub :authenticate! => user
      allow(controller).to receive(:current_user) { user }
    end
  end

end



