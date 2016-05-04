class Api::V1::KomaLabelsController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  def index
    label_id = params[:id]
    data = KomaLabel.all.select(:id, :company_id, :label_order, :label_text, :created_at, :updated_at).order("created_at DESC")
    results = Array.new()
    data.each do |row|
      results.push({id: row['id'], company_id: row['company_id'], label_order: row['label_order'], label_text: row['label_text'], created_at: row['created_at'], updated_at: row['updated_at']})
    end
    render json: results
  end

  def show
    label_id = params[:id].to_i()

    data = KomaLabel.select(:id, :company_id, :label_order, :label_text, :created_at, :updated_at).find(label_id)

    if data == nil
      result = {result: false, message: "Cannot find koma_label by id: #{koma_id}" }
    else
      result = {result: true, id: data["id"], company_id: data['company_id'], label_order: data['label_order'], label_text: data['label_text'], created_at: data['created_at'], updated_at: data['updated_at']}
    end
    render json: result
  end

  def create
    param_company_id = params[:company_id]
    param_label_order = params[:label_order]
    param_label_text = params[:label_text]
    ret = validate_koma_label_create(param_company_id, param_label_order, param_label_text)
    if ret[:result]
      ret = create_koma_label(param_company_id, param_label_order, param_label_text)
      render json: ret
    else
      render json: ret
    end

  end

  private def create_koma_label(company_id, label_order, label_text)
    data = KomaLabel.create(company_id: company_id, label_order: label_order, label_text: label_text)
    ret =  {result: true, id: data["id"], company_id: data['company_id'], label_order: data['label_order'], label_text: data['label_text'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Koma Label has been created successfully." }
    return ret
  end

  def update
    param_label_id = params[:id]
    param_company_id = params[:company_id]
    param_label_order = params[:label_order]
    param_label_text = params[:label_text]
    ret = validate_koma_label_update(param_label_id, param_company_id, param_label_order, param_label_text)
    if ret[:result]
      ret = update_koma_label(param_label_id, param_company_id, param_label_order, param_label_text)
      render json: ret
    else
      render json: ret
    end
  end

  private def update_koma_label(label_id, company_id, label_order, label_text)
    KomaLabel.where("id = ?", label_id).update_all({:company_id=> company_id, :label_order  => label_order, :label_text => label_text})
    data = KomaLabel.find_by(id: label_id)
    ret =  {result: true, id: data["id"], company_id: data['company_id'], label_order: data['label_order'], label_text: data['label_text'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Koma Label has been updated successfully." }
    return ret
  end

  def destroy
    param_id = params[:id].to_i()
    data = KomaLabel.find_by(id: param_id)
    if data == nil
      render json: {result: false, message: "Koma Label id: #{param_id} cannot be found."}
      return
    end
    data.destroy()

    render json: {result: true, id: data['id'], message: "Koma Label has been deleted." }
  end

  private def validate_koma_label_create(company_id, label_order, label_text)
    rows = KomaLabel.select(:id).where("company_id = ? and label_order = ?", company_id, label_order)
    if rows.length >  0
      return {result: false, message: "Koma Label already exists for company id: #{company_id} and label_order - #{label_order}."}
    end
    return {result: true}
  end

  private def validate_koma_label_update(label_id, company_id, label_order, label_text)
    data = KomaLabel.find_by(id: label_id)
    if data == nil
      render json: {result: false, message: "Koma Label id: #{label_id} cannot be found."}
      return
    end
    rows = KomaLabel.select(:id).where("id <> ? and company_id = ?  and label_order = ?", label_id, company_id, label_order)
    if rows.length > 0
      return {result: false, message: "Koma Label already exists for company id: #{company_id} and label_order - #{label_order}."}
    end
    return {result: true}
  end
end
