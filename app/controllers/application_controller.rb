require 'houston'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  if Rails.configuration.x.apn.mode == "development"
    APN = Houston::Client.development
  else
    APN = Houston::Client.production
  end
  
  APN.certificate = File.read(Rails.configuration.x.apn.pem_file_path)
  
  def authenticate
 
     controller = params[:controller]
     action = params[:action]
     user_id = session[:user_id]
     username = session[:username]
     logger.debug("Authenticating as {user_id: #{user_id}, username: #{username}} for controller: #{controller}, action: #{action}")
     if !is_accessible(controller,action)
       render :nothing => true, :status => :unauthorized
     end
   end
 
   private def is_accessible(controller, action)
     login = session[:user_id] == nil ? false : true
     if login
       return is_accessible_by_user(controller, action)
     end
     return is_accessible_by_guest(controller, action)
   end
 
   private def is_accessible_by_user(controller, action)
     if controller.start_with?("api/v3")
       if controller.start_with?("api/v3/login") || 
         controller.start_with?("api/v3/komas")   || 
         controller.start_with?("api/v3/koma_users") ||
         controller.start_with?("api/v3/devices") ||
         controller.start_with?("api/v3/koma_messages")
          return true
       else
          return false
        end
     end
     return true
     
   end
 
   private def is_accessible_by_guest(controller, action)
     if controller.start_with?("api/v3")
       if controller.start_with?("api/v3/login")
         return true
       else
         return false
       end
     end
     return true
   end
end
