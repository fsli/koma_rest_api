require 'houston'
module NotificationsHelper
  APN = Houston::Client.production
  APN.certificate = File.read(Rails.configuration.x.apn.pem_file_path)
  def self.create_notification(user_id, message, badge)
    data = Notification.create(user_id: user_id, message: message, badge: badge)
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  badge: data['badge'], message: "Notification has been created." }
    return ret
  end
  
  def self.send_all_notifications
    data = Notification.joins('INNER JOIN devices ON notifications.user_id = devices.user_id').select("notifications.user_id as user_id, notifications.message as message, notifications.badge as badge, devices.device_token AS device_token").where(:is_pushed => false).order("notifications.created_at ASC")
    for row in data
      token = row['device_token']
      notification = Houston::Notification.new(device: token)
      if row['message'].empty? == false
        notification.alert = row['message']
      end
      notification.badge = row['badge']
      APN.push(notification)
    end
    Notification.update_all(:is_pushed => true)
  end
end
