class Api::V1::KomaUsersController < ApplicationController
    skip_before_filter  :verify_authenticity_token
    def index
      user_id = params[:id]
      data = KomaUser.all.select(:id,:username, :attr, :created_at, :updated_at, :company_id, :nickname, :picture_url, :facebook_id, :badge_number).order("created_at DESC")
      results = Array.new()
      data.each do |row|
        results.push({id: row['id'], username: row['username'], attr: row['attr'], created_at: row['created_at'], updated_at: row['updated_at'], company_id: row['company_id'], nickname: row['nickname'], picture_url: row['picture_url'], facebook_id: row['facebook_id'], badge_number: row['badge_number']})
      end
      render json: results
    end
  
    def show
      user_id = params[:id].to_i()     
      data = KomaUser.select(:id, :username, :attr, :created_at, :updated_at, :company_id, :nickname, :picture_url, :facebook_id, :badge_number).find(user_id)
   
      if data == nil
        result = {result: false, message: "Cannot find user by id: #{user_id}" }
      else
        result = {result: true, id: data["id"], username: data['username'], attr: data['attr'], created_at: data['created_at'], updated_at: data['updated_at'], company_id: data['company_id'], nickname: data['nickname'], picture_url: data['picture_url'], facebook_id: data['facebook_id'], badge_number: data['badge_number']}
      end
      render json: result
    end
  
    def create
      param_username = params[:username]
      param_attr = params[:attr]
      param_company_id = params[:company_id]
      param_nickname = params[:nickname]
      param_picture_url = params[:picture_url]
      param_facebook_id = params[:facebook_id]
      param_badge_number = params[:badge_number]
      ret = validate_koma_user_create
      if ret[:result]      
        ret = create_user(param_username, param_attr, param_company_id, param_nickname, param_picture_url, param_facebook_id, param_badge_number)
        render json: ret
      else
        render json: ret
      end
    end
  
    private def create_user(username, attribute, company_id, nickname, picture_url, facebook_id, badge_number) 
      
      user = KomaUser.create(username: username, attr: attribute, company_id: company_id, nickname: nickname, picture_url: picture_url, facebook_id: facebook_id, badge_number: badge_number.nil? ? 0 : badge_number)
      ret =  {result: true, id: user['id'], username: user['username'],  attr: user['attr'], company_id: user['company_id'], nickname: user['nickname'], picture_url: user['picture_url'], facebook_id:user['facebook_id'], badge_number: user['badge_number'], message: "User has been created successfully." }
      return ret
    end
    
    def update
      partial_update = false
      if request.method_symbol.to_s() == 'patch'
        partial_update = true
      end
      param_id = params[:id]
      param_username = params[:username]
      param_attr = params[:attr]
      param_company_id = params[:company_id]
      param_nickname = params[:nickname]
      param_picture_url = params[:picture_url]
      param_facebook_id = params[:facebook_id]
      param_badge_number = params[:badge_number]
      ret = validate_koma_user_update
      if ret[:result]
        user = KomaUser.find_by(id: param_id)
        if user == nil
          render json: {result: false, message: "User id: #{param_id} cannot be found."}   
          return
        end
        ret = update_user(user, partial_update, param_username, param_attr, param_company_id, param_nickname, param_picture_url, param_facebook_id, param_badge_number)

        render json: ret
      else
        render json: ret
      end
    end
  
    private def update_user(user, is_partial_update, username, attribute, company_id, nickname, picture_url, facebook_id, badge_number)
      if is_partial_update
        if username.nil? == false
          user.update(username: username)
        end
        if attribute.nil? == false
          user.update(attr: attribute)          
        end
        if company_id.nil? == false
          user.update(company_id: company_id)
        end
        if nickname.nil? == false
          
          user.update(nickname: nickname)
        end
        if picture_url.nil? == false
          user.update(picture_url: picture_url)
        end
        if facebook_id.nil? == false
          user.update(facebook_id: facebook_id)
        end
        if badge_number.nil? == false
          user.update(badge_number: badge_number)
        end
      else
        user.update(username: username, attr: attribute, company_id: company_id, nickname: nickname, picture_url: picture_url, facebook_id: facebook_id, badge_number: badge_number)
      end
      
      ret =  {result: true, id: user['id'], username: user['username'],  attr: user['attr'], company_id: user['company_id'], nickname: user['nickname'], picture_url: user['picture_url'], facebook_id:user['facebook_id'], badge_number: user['badge_number'], message: "User has been updated successfully." }
      return ret
    end
    
    def destroy
      param_id = params[:id].to_i()
      user = KomaUser.find_by(id: param_id)
      if user == nil
        render json: {result: false, message: "User id: #{param_id} cannot be found."}    
        return
      end 
      user.destroy()

      render json: {restul: true, id: user['id'], message: "User has been deleted successfully." }    
    end
  
    private def validate_koma_user_create
      param_username = params[:username]
      if param_username != nil
        data = KomaUser.where(username: param_username)
        if data.length > 0
          return {result: false, message: "Username #{param_username} already exists."}
        end
      end
      return {result: true}
    end
  
    private def validate_koma_user_update
      param_username = params[:username]
      param_id = params[:id].to_i
      if param_username != nil
        data = KomaUser.where(username: param_username)
        for u in data
          if u.id != param_id.to_i && u.username == param_username
            return {result: false, message: "Username #{param_username} already exists."}
          end
        end
      end
      return {result: true}
    end
end
