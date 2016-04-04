
class Api::V1::OperationsController < ApplicationController
  include NotificationsHelper
  
  skip_before_filter  :verify_authenticity_token
  def index
    render :nothing => true, :status => :method_not_allowed
  end
  def create
    param_type = params[:type]
    ret = validate_operation_type(param_type)
    if ret[:result]
      if param_type == 'increase_badge_number'
        ret = do_increase_badge_number()
      elsif param_type == 'send_notification_to_user'
        ret = do_send_notification_to_user()
      elsif param_type == 'send_notification_to_company'
        ret = do_send_notification_to_company()
      end
      render json: ret
    else
      render json: ret
    end
  end
  
  
  
  private def validate_operation_type(type)
    is_valid = false
    if type == 'increase_badge_number'
      is_valid = true
    elsif type == 'send_notification_to_user'
      is_valid = true
    elsif type == 'send_notification_to_company'
      is_valid = true
    end
    if is_valid
      return {result: true, message: "Operation: '#{type}' has been executed."}
    else
      return {result: false, message: 'Invalid operation type.'}
    end
    
  end
  
  private def do_increase_badge_number
    param_user_id = params[:user_id]
    param_is_pushed = params[:is_pushed]
    if param_user_id.nil?
      return {result: false, message: 'user_id is required for increase_badge_number'} 
    end
    user = KomaUser.find_by(id: param_user_id)
    if user.nil?
      return {result: false, message: "Failed to find KomaUser by user_id: #{param_user_id}."} 
    end
    KomaUser.increment_counter(:badge_number, param_user_id)
    is_pushed = false
    ret = {result: true, message: "Badge number has been increased by 1 for user_id: #{param_user_id}"}
    if param_is_pushed == 'true'
      user = KomaUser.find_by(id: param_user_id)
      devices = Device.where(:user_id => param_user_id)
      for device in devices
        token = device['device_token']
        notification = Houston::Notification.new(device: token)
        notification.badge = user['badge_number']
        APN.push(notification)
        is_pushed = true
      end
    end
    if is_pushed
      ret[:message] = ret[:message] + " and pushed to user's device(s)"
    end
    ret[:message] = ret[:message] +  "."
    return ret
  end
  
  private def do_send_notification_to_user
    param_user_id = params[:user_id]
    param_message = params[:message]
    if param_user_id.nil?
      return {result: false, message: 'user_id is required for send_notification_to_user'} 
    end
    user = KomaUser.find_by(id: param_user_id)
    if user.nil?
      return {result: false, message: "Failed to find KomaUser by user_id: #{param_user_id}."} 
    end
    KomaUser.increment_counter(:badge_number, param_user_id)
    user = KomaUser.find_by(id: param_user_id)
    NotificationsHelper.create_notification(param_user_id, param_message, user['badge_number'])
    NotificationsHelper.send_all_notifications()
    ret = {result: true, message: "Message has been sent&pushed to devices of user_id: #{param_user_id}."}
    return ret
  end
  
  private def do_send_notification_to_company
    param_company_id = params[:company_id]
    param_message = params[:message]
    if param_company_id.nil?
      return {result: false, message: 'company_id is required for send_notification_to_company'} 
    end
    users = KomaUser.where(company_id: param_company_id)
    if users.nil? || users.length == 0
      return {result: false, message: "Failed to find KomaUser by company_id: #{param_company_id}."} 
    end
    for user in users
      KomaUser.increment_counter(:badge_number, user['id'])
      NotificationsHelper.create_notification(user['id'], param_message, user['badge_number'])
    end
    
    NotificationsHelper.send_all_notifications()
    ret = {result: true, message: "Message has been sent&pushed to devices of company_id: #{param_company_id}."}
    return ret
  end
  
  def update
    render :nothing => true, :status => :method_not_allowed
  end
  
  def destroy
    render :nothing => true, :status => :method_not_allowed
  end
end
