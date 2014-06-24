require 'spec_helper'
describe CurrenciesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

end