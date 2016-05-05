class Api::V2::DevicesController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  def index
    data = Device.all.select(:id, :device_token, :user_id).order("created_at DESC")
    results = Array.new()
    data.each do |row|
      results.push({id: row['id'], device_token: row['device_token'], user_id: row['user_id']})
    end
    render json: results
  end

  def create
    param_device_token = params[:device_token]
    param_user_id = params[:user_id]
    ret = validate_device_create
    if ret[:result]
      ret = create_device(param_device_token, param_user_id)
      render json: ret
    else
      render json: ret
    end
  end
  
  def update
    param_device_token = params[:device_token]
    param_user_id = params[:user_id]
    ret = validate_device_update
    if ret[:result]
      ret = upsert_device(param_device_token, param_user_id)
      render json: ret
    else
      render json: ret
    end
  end
  
  private def validate_device_create
    param_device_token = params[:device_token]
    param_user_id = params[:user_id]  
    if param_device_token.nil? || param_device_token.empty?
      return {result: false, message: "device_token is required."}
    end
    if param_user_id.nil? || param_user_id.empty?
      return {result: false, message: "user_id is required."}
    end
    return {result: true}
  end
  
  private def validate_device_update
    param_device_token = params[:device_token]
    param_user_id = params[:user_id]  
    if param_device_token.nil? || param_device_token.empty?
      return {result: false, message: "device_token is required."}
    end
    if param_user_id.nil? || param_user_id.empty?
      return {result: false, message: "user_id is required."}
    end
    return {result: true}
  end
  
  private def create_device(device_token, user_id)
    Device.where("device_token = :device_token", {:device_token => device_token}).destroy_all()
    data = Device.create(device_token: device_token, user_id: user_id)
    ret =  {result: true, id: data['id'], device_token: data['device_token'],  user_id: data['user_id'], message: "Device has been created." }
    return ret
  end
  
  private def upsert_device(device_token, user_id)
    devices = Device.where("device_token = :device_token", {:device_token => device_token})
    if devices.length > 0
      for data in devices
        if data['user_id'] == user_id.to_i()
          ret = {result: true, id: data['id'], device_token: data['device_token'],  user_id: data['user_id'], message: "Device is already registered with user id: #{user_id}." }
        else
          data.update(user_id: user_id)
        ret =  {result: true, id: data['id'], device_token: data['device_token'],  user_id: data['user_id'], message: "Device has been updated." }
        end
      end
    else
      data = Device.create(device_token: device_token, user_id: user_id)
      ret =  {result: true, id: data['id'], device_token: data['device_token'],  user_id: data['user_id'], message: "Device has been created." }
    end
    return ret
  end
end
