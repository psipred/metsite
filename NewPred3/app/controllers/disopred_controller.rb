class DisopredController < ApplicationController

  def index
    redirect_to :controller => 'psipred', :action => 'index', :disopred => "1"
  end

end