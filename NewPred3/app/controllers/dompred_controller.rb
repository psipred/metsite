class DompredController < ApplicationController

  def index
    redirect_to :controller => 'psipred', :action => 'index', :dompred => "1"
  end

end
