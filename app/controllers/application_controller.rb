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
end
