module CocomoExpert
  class ApplicationController < ActionController::Base
    protected
    def url_for options=nil
      begin
        super options
      rescue ActionController::RoutingError
        main_app.url_for options
      end
    end
  end
end
