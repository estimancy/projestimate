require 'spec_helper'

describe ApplicationController do
  before do
    sign_in
    @connected_user = controller.current_user
  end


end