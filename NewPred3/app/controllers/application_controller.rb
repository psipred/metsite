# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  #include AuthenticatedSystem  
  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_NewPred3_session_id'

   #protected
   # def authorized?
   #    logged_in? && (request.post? || current_user.admin?)
   # end
    
end
