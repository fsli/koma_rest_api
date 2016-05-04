class Api::V1::CompaniesController < ApplicationController
  skip_before_filter  :verify_authenticity_token
    def index
      data = Company.all.select(:id, :company_name, :account_status, :admin_email, :admin_pass, :company_url, :created_at, :updated_at).order("created_at DESC")
      results = Array.new()
      data.each do |row|
        results.push({id: row['id'], company_name: row['company_name'], account_status: row['account_status'], admin_email: row['admin_email'], admin_pass: row['admin_pass'], company_url: row['company_url'], created_at: row['created_at'], updated_at: row['updated_at']})
      end
      render json: results
    end
  
    def show
      company_id = params[:id].to_i()
      data = Company.select(:id, :company_name, :account_status, :admin_email, :admin_pass, :company_url, :created_at, :updated_at).find(company_id)
      if data == nil
        result = {result: false, message: "Cannot find company by id: #{company_id}" }
      else
        result = {id: data['id'], company_name: data['company_name'], account_status: data['account_status'], admin_email: data['admin_email'], admin_pass: data['admin_pass'], company_url: data['company_url'], created_at: data['created_at'], updated_at: data['updated_at']}
      end
      render json: result
    end
  
    def create
      param_company_name = params[:company_name]
      param_account_status = params[:account_status]
      param_admin_email = params[:admin_email]
      param_admin_pass = params[:admin_pass]
      param_company_url = params[:company_url]
      ret = validate_company_create
      if ret[:result]
        ret = create_company(param_company_name, param_account_status, param_admin_email, param_admin_pass, param_company_url)
        render json: ret
      else
        render json: ret
      end
  
    end
  
    private def create_company(company_name, account_status, admin_email, admin_pass, company_url)
      data = Company.create(company_name: company_name, account_status: account_status == nil || account_status.empty? ? 0 : account_status, admin_email: admin_email, admin_pass: admin_pass, company_url: company_url)
      ret =  {result: true, id: data['id'], company_name: data['company_name'], account_status: data['account_status'], admin_email: data['admin_email'], admin_pass: data['admin_pass'], company_url: data['company_url'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Company has been created successfully." }
      return ret
    end
  
    def update
      param_company_id = params[:id]
      param_company_name = params[:company_name]
      param_account_status = params[:account_status]
      param_admin_email = params[:admin_email]
      param_admin_pass = params[:admin_pass]
      param_company_url = params[:company_url]
      ret = validate_company_update(param_company_id)
      if ret[:result]
        ret = update_company(param_company_id, param_company_name, param_account_status, param_admin_email, param_admin_pass, param_company_url)
        render json: ret
      else
        render json: ret
      end
    end
  
    private def update_company(company_id, company_name, account_status, admin_email, admin_pass, company_url)
      Company.where("id = ?", company_id).update_all({:company_name=> company_name, :account_status  => account_status, :admin_email => admin_email, :admin_pass => admin_pass, :company_url => company_url})
      data = Company.find_by(id: company_id)
      ret =  {result: true, id: data['id'], company_name: data['company_name'], account_status: data['account_status'], admin_email: data['admin_email'], admin_pass: data['admin_pass'], company_url: data['company_url'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Company has been updated successfully." }
      return ret
    end
  
    def destroy
      param_id = params[:id].to_i()
      data = Company.find_by(id: param_id)
      if data == nil
        render json: {result: false, message: "Company id: #{param_id} cannot be found."}
        return
      end
      data.destroy()
  
      render json: {result: true, id: data['id'], message: "Company has been deleted." }
    end
  
    private def validate_company_create
      return {result: true}
    end
  
    private def validate_company_update(company_id)
      data = Company.find_by(id: company_id)
      if data == nil
        render json: {result: false, message: "Company id: #{company_id} cannot be found."}
        return
      end
      return {result: true}
    end
end
