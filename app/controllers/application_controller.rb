require 'houston'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  APN = Houston::Client.production
  APN.certificate = File.read("./development_moteve_apns_sample.pem")
end
