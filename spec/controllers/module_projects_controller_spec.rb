require 'spec_helper'
describe ModuleProjectsController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

end