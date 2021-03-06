module Api::V1::NotificationsHelper
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
  end
end
