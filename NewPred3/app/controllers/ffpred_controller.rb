class FfpredController < ApplicationController

  def index
        redirect_to :controller => 'psipred', :action => 'index', :ffpred => "1"
  end

end