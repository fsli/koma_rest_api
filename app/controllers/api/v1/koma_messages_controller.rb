class Api::V1::KomaMessagesController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  def index
    user_id = params[:user_id]
    company_id = params[:company_id]
    range_start = params[:range_start]
    range_end = params[:range_end]
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
      conditions += "company_id = :company_id"
      condition_params[:company_id] = company_id
      use_conditions = true
    end
    offset = range_start.to_i()
    limit = range_end.to_i() - range_start.to_i()
    if limit <= 0
      limit = 65535
    end

    if !use_conditions
      data = KomaMessage.all.select(:id, :user_id, :company_id, :content, :url, :oko, :attr, :read_by, :created_at, :updated_at).limit(limit).offset(offset).order("created_at DESC")
    else
      data = KomaMessage.all.select(:id, :user_id, :company_id, :content, :url, :oko, :attr, :read_by, :created_at, :updated_at).where(conditions, condition_params).limit(limit).offset(offset).order("created_at DESC")
    end
    results = Array.new()
    data.each do |row|
      results.push({id: row['id'], user_id: row['user_id'], company_id: row['company_id'], content: row['content'], url: row['url'], oko: row['oko'], attr: row['attr'], read_by: row['read_by'], created_at: row['created_at'], updated_at: row['updated_at']})
    end
    render json: results
  end

  def show
    koma_message_id = params[:id].to_i()
    row = KomaMessage.select(:id, :user_id, :company_id, :content, :url, :oko, :attr, :read_by, :created_at, :updated_at).find(koma_message_id)
    if row == nil
      result = {result: false, message: "Cannot find Koma Message by id: #{koma_message_id}" }
    else
      result = {result: true, id: row['id'], user_id: row['user_id'], company_id: row['company_id'], content: row['content'], url: row['url'], oko: row['oko'], attr: row['attr'], read_by: row['read_by'], created_at: row['created_at'], updated_at: row['updated_at']}
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
    ret = validate_koma_message_create(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by)
    if ret[:result]
      ret = create_koma_message(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by)
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
    ret = validate_koma_message_update(param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by)
    if ret[:result]
      data = KomaMessage.find_by(id: param_id)
      if data.nil?
        render json: {result: false, message: "Koma message id: #{param_id} cannot be found."}
        return
      end
      ret = update_koma_message(data, param_user_id, param_company_id, param_content, param_url, param_oko, param_attr, param_read_by)
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
  
  private def create_koma_message(user_id, company_id, content, url, oko, attr, read_by)
    data = KomaMessage.create(user_id: user_id, company_id: company_id, content: content, url: url, oko: (oko.nil? ? 0 : oko), attr: (attr.nil? ? 0 : attr), read_by: (read_by.nil? ? 0 : read_by))
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  company_id: data['company_id'], content: data['content'], url: data['url'], oko:data['oko'], attr: data['attr'], read_by: data['read_by'], message: "Koma message has been created." }
    return ret
  end
  
  private def update_koma_message(data, user_id, company_id, content, url, oko, attr, read_by)
    data.update(user_id: user_id, company_id: company_id, content: content, url: url, oko: oko, attr: attr, read_by: read_by)
    ret =  {result: true, id: data['id'], user_id: data['user_id'],  company_id: data['company_id'], content: data['content'], url: data['url'], oko:data['oko'], attr: data['attr'], read_by: data['read_by'], message: "Koma message has been updated." }
    return ret
  end

  private def validate_koma_message_create(user_id, company_id, content, url, oko, attr, read_by)
    if user_id.nil? || user_id.empty?
        return {result: false, message: "user_id is required."}
    end
    if company_id.nil? || company_id.empty?
        return {result: false, message: "company_id is required."}
    end
    return {result: true}
  end

  private def validate_koma_message_update(user_id, company_id, content, url, oko, attr, read_by)
    if user_id.nil? || user_id.empty?
      return {result: false, message: "user_id is required."}
    end
    if company_id.nil? || company_id.empty?
      return {result: false, message: "company_id is required."}
    end
    return {result: true}
  end
end
