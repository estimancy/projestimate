require 'spec_helper'

describe AttributeOrganizationsController do
  before do
    sign_in
    @connected_user = controller.current_user
  end
end
