class Api::Admin::KomaMessagesController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  def index
    user_id = params[:user_id]
    company_id = params[:company_id]
    range_start = params[:range_start]
    range_end = params[:range_end]
    created_before = params[:created_before]
    created_after = params[:created_after]
    use_conditions = false
    condition_params = {}
    conditions = ""
    
    if !user_id.nil? && !user_id.empty?
      conditions += " user_id = :user_id "
      condition_params[:user_id] = user_id
      use_conditions = true
    end
    if !company_id.nil? && !company_id.empty?
      if use_conditions
        conditions += " AND "
      end
      conditions += "koma_messages.company_id = :company_id"
      condition_params[:company_id] = company_id
      use_conditions = true
    end
    offset = range_start.to_i()
    limit = range_end.to_i() - range_start.to_i()
    if limit <= 0
      limit = 65535
    end
    if created_before != nil && created_before != ''
      if use_conditions
        conditions += " AND "
      end
      conditions += "koma_messages.created_at < :created_before"
      condition_params[:created_before] = DateTime.strptime(created_before, "%m/%d/%Y %H:%M")
      use_conditions = true
    end
    if created_after != nil && created_after != ''
      if use_conditions
        conditions += " AND "
      end
      conditions += " koma_messages.created_at >= :created_after "
      condition_params[:created_after] = DateTime.strptime(created_after, "%m/%d/%Y %H:%M")
      use_conditions = true
    end
    selected_columns = "koma_messages.id, user_id, koma_users.username as username, koma_messages.company_id as company_id, content, url, oko, koma_messages.attr as attr, read_by, sender_user_id, B.username as sender_username, koma_messages.created_at as created_at, koma_messages.updated_at as updated_at"
    joined_tables = 'LEFT OUTER JOIN koma_users ON koma_messages.user_id = koma_users.id LEFT OUTER JOIN koma_users B on koma_messages.sender_user_id = B.id'
    if !use_conditions
      total_count = KomaMessage.joins(joined_tables).select("*").count
      data = KomaMessage.joins(joined_tables).select(selected_columns).limit(limit).offset(offset).order("created_at DESC")
    else
      total_count = KomaMessage.joins(joined_tables).select("*").where(conditions, condition_params).count
      data = KomaMessage.joins(joined_tables).select(selected_columns).where(conditions, condition_params).limit(limit).offset(offset).order("created_at DESC")
    end
    results = Array.new()
    data.each do |row|
      results.push({id: row['id'], user_id: row['user_id'], username: row['username'], company_id: row['company_id'], content: row['content'], url: row['url'], oko: row['oko'], attr: row['attr'], read_by: row['read_by'], sender_user_id: row['sender_user_id'], sender_username: row['sender_username'], created_at: row['created_at'], updated_at: row['updated_at']})
    end
    render json: results
  end

  def show
    koma_message_id = params[:id].to_i()
    selected_columns = "koma_messages.id, user_id, koma_users.username as username, koma_users.company_id as company_id, content, url, oko, koma_messages.attr as attr, read_by, sender_user_id, B.username as sender_username, koma_messages.created_at as created_at, koma_messages.updated_at as updated_at"
    joined_tables = 'LEFT OUTER JOIN koma_users ON koma_messages.user_id = koma_users.id LEFT OUTER JOIN koma_users B on koma_messages.sender_user_id = B.id'
    row = KomaMessage.joins(joined_tables).select(selected_columns).find(koma_message_id)
    if row == nil
      result = {result: false, message: "Cannot find Koma Message by id: #{koma_message_id}" }
    else
      result = {result: true, id: row['id'], user_id: row['user_id'], username: row['username'], company_id: row['company_id'], content: row['content'], url: row['url'], oko: row['oko'], attr: row['attr'], read_by: row['read_by'], sender_user_id: row['sender_user_id'], sender_username: row['sender_username'], created_at: row['created_at'], updated_at: row['updated_at']}
    end
    render json: result
  end

  def create
    param_user_id = params[:user_id]
    param_company_id = params[:company_id]
    param_content = params[:content]
    param_url = params[:url]
    param_oko = params[:oko]
    param_attr = params[:attr]
    param_read_by = params[:read_by]
    param_sender_user_id = params[:sender_user_id]
    ret = validate_koma_message_create(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by, param_sender_user_id)
    if ret[:result]
      ret = create_koma_message(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by, param_sender_user_id)
      render json: ret
    else
      render json: ret
    end
  end

  def update
    param_id = params[:id]
    param_user_id = params[:user_id]
    param_company_id = params[:company_id]
    param_content = params[:content]
    param_url = params[:url]
    param_oko = params[:oko]
    param_attr = params[:attr]
    param_read_by = params[:read_by]
    param_sender_user_id = params[:sender_user_id]
    ret = validate_koma_message_update(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by, param_sender_user_id)
    if ret[:result]
      data = KomaMessage.find_by(id: param_id)
      if data.nil?
        render json: {result: false, message: "Koma message id: #{param_id} cannot be found."}
        return
      end
      ret = update_koma_message(data, param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by, param_sender_user_id)
      render json: ret
    else
      render json: ret
    end
  end

  def destroy
    param_id = params[:id].to_i()
    data = KomaMessage.find_by(id: param_id)
    if data == nil
      render json: {result: false, message: "Koma Message id: #{param_id} cannot be found."}    
      return
    end 
    data.destroy()

    render json: {restul: true, id: data['id'], message: "Koma Message has been deleted." }    
  end
  
  private def create_koma_message(user_id, company_id, content, url, oko, attr, read_by, sender_user_id)
    data = KomaMessage.create(user_id: user_id, company_id: company_id, content: content, url: url, oko: (oko.nil? ? 0 : oko), attr: (attr.nil? ? 0 : attr), read_by: (read_by.nil? ? 0 : read_by), sender_user_id: (sender_user_id.nil? ? 0 : sender_user_id))
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  company_id: data['company_id'], content: data['content'], url: data['url'], oko:data['oko'], attr: data['attr'], read_by: data['read_by'], sender_user_id: data['sender_user_id'], message: "Koma message has been created." }
    return ret
  end
  
  private def update_koma_message(data, user_id, company_id, content, url, oko, attr, read_by, sender_user_id)
    data.update(user_id: user_id, company_id: company_id, content: content, url: url, oko: oko, attr: attr, read_by: read_by, sender_user_id: sender_user_id)
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  company_id: data['company_id'], content: data['content'], url: data['url'], oko:data['oko'], attr: data['attr'], read_by: data['read_by'], sender_user_id: data['sender_user_id'], message: "Koma message has been updated." }
    return ret
  end

  private def validate_koma_message_create(user_id, company_id, content, url, oko, attr, read_by, sender_user_id)
    if user_id.nil? || user_id.empty?
        return {result: false, message: "user_id is required."}
    end
    if company_id.nil? || company_id.empty?
        return {result: false, message: "company_id is required."}
    end
    return {result: true}
  end

  private def validate_koma_message_update(user_id, company_id, content, url, oko, attr, read_by, sender_user_id)
    if user_id.nil? || user_id.empty?
      return {result: false, message: "user_id is required."}
    end
    if company_id.nil? || company_id.empty?
      return {result: false, message: "company_id is required."}
    end
    return {result: true}
  end
end
