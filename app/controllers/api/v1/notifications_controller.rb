require 'houston'

class Api::V1::NotificationsController < ApplicationController
  APN = Houston::Client.production
  APN.certificate = File.read("./development_moteve_apns_sample.pem")
  skip_before_filter  :verify_authenticity_token
  def index
    data = Notification.all.select(:id, :user_id, :message, :badge, :is_pushed, :created_at, :updated_at).order("created_at DESC")
    results = Array.new()
    data.each do |row|
      results.push({id: row['id'], user_id: row['user_id'], message: row['message'], badge: row['badge'], is_pushed: row['is_pushed'], created_ad: row['created_at'], updated_at: row['updated_at']})
    end
    render json: results
  end

  def create
    param_user_id = params[:user_id]
    param_message = params[:message]
    param_badge = params[:badge]
    ret = validate_notification_create
    if ret[:result]
      ret = create_notification(param_user_id, param_message, param_badge)
      render json: ret
    else
      render json: ret
    end
  end

  def update
    param_is_pushed = params[:is_pushed]
    if param_is_pushed == 'true'
      send_all_notifications
      Notification.update_all(:is_pushed => true)
    elsif
      Notification.update_all(:is_pushed => false)
    end
    ret = {:result=> true}
    if ret[:result]
      render json: ret
    else
      render json: ret
    end
  end

  private def send_all_notifications
    data = Notification.joins('INNER JOIN devices ON notifications.user_id = devices.user_id').select("notifications.user_id as user_id, notifications.message as message, notifications.badge as badge, devices.device_token AS device_token").where(:is_pushed => false).order("notifications.created_at ASC")
    for row in data
      token = row['device_token']
      notification = Houston::Notification.new(device: token)
      notification.alert = row['message']
      notification.badge = row['badge']
      APN.push(notification)
    end
  end
  
  private def validate_notification_create
    param_user_id = params[:user_id]
    param_message = params[:message]
    param_badge = params[:badge]
    if param_user_id.nil? || param_user_id.empty?
      return {result: false, message: "user_id is required."}
    end
    if param_message.nil? || param_message.empty?
      return {result: false, message: "massage is required."}
    end
    if param_badge.nil? || param_badge.empty?
      return {result: false, message: "badge is required."}
    end
    return {result: true}
  end

  private def create_notification(user_id, message, badge)
    data = Notification.create(user_id: user_id, message: message, badge: badge)
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  badge: data['badge'], message: "Notification has been created." }
    return ret
  end
end
