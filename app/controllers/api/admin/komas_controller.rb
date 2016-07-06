class Api::Admin::KomasController < ApplicationController
  skip_before_filter  :verify_authenticity_token
      def index
        koma_id = params[:id]
        owner_id = params[:owner_id]
        created_before = params[:created_before]
        created_after = params[:created_after]
        koma_date_before = params[:koma_date_before]
        koma_date_after = params[:koma_date_after]
        use_conditions = false
        condition_params = {}
        conditions = ""
        if owner_id != nil && owner_id != ''
          conditions += " owner_id = :owner_id "
          condition_params[:owner_id] = owner_id
          use_conditions = true
        end
        if created_before != nil && created_before != ''
          if use_conditions
            conditions += " AND "
          end
          conditions += "created_at < :created_before"
          condition_params[:created_before] = DateTime.strptime(created_before, "%m/%d/%Y %H:%M")
          use_conditions = true
        end
        if created_after != nil && created_after != ''
          if use_conditions
            conditions += " AND "
          end
          conditions += " created_at >= :created_after "
          condition_params[:created_after] = DateTime.strptime(created_after, "%m/%d/%Y %H:%M")
          use_conditions = true
        end
        if koma_date_before != nil && koma_date_before != ''
          if use_conditions
            conditions += " AND "
          end
          conditions += "koma_date < :koma_date_before"
          condition_params[:koma_date_before] = DateTime.strptime(koma_date_before, "%m/%d/%Y %H:%M")
          use_conditions = true
        end
        if koma_date_after != nil && koma_date_after != ''
          if use_conditions
            conditions += " AND "
          end
          conditions += " koma_date >= :koma_date_after "
          condition_params[:koma_date_after] = DateTime.strptime(koma_date_after, "%m/%d/%Y %H:%M")
          use_conditions = true
        end
        if !use_conditions
          data = Koma.all.select(:id, :owner_id, :koma_date, :koma_type, :prospect_name, :memo, :created_at, :updated_at).order("created_at DESC")
        else
          data = Koma.all.select(:id, :owner_id, :koma_date, :koma_type, :prospect_name, :memo, :created_at, :updated_at).where(conditions, condition_params).order("created_at DESC")
        end
        results = Array.new()
        data.each do |row|
          results.push({id: row['id'], owner_id: row['owner_id'], koma_date: row['koma_date'], koma_type: row['koma_type'], prospect_name: row['prospect_name'], memo: row['memo'], created_at: row['created_at'], updated_at: row['updated_at']})
        end
        render json: results
      end
    
      def show
        koma_id = params[:id].to_i()
       
        data = Koma.select(:id, :owner_id, :koma_date, :koma_type, :prospect_name, :memo, :created_at, :updated_at).find(koma_id)
     
        if data == nil
          result = {result: false, message: "Cannot find koma by id: #{koma_id}" }
        else
          result = {result: true, id: data["id"], owner_id: data['owner_id'], koma_date: data['koma_date'], koma_type: data['koma_type'], prospect_name: data['prospect_name'], memo: data['memo'], created_at: data['created_at'], updated_at: data['updated_at']}
        end
        render json: result
      end
    
      def create
        param_owner_id = params[:owner_id]
        param_koma_date = params[:koma_date]
        param_koma_type = params[:koma_type]
        param_prospect_name = params[:prospect_name]
        param_memo = params[:memo]
        ret = validate_koma_create(param_owner_id, param_koma_date, param_koma_type, param_prospect_name, param_memo)
        if ret[:result]
          ret = create_koma(param_owner_id, param_koma_date, param_koma_type, param_prospect_name, param_memo)
          render json: ret
        else
          render json: ret
        end
        

      end
    
      private def create_koma(owner_id, koma_date, koma_type, prospect_name, memo) 
        data = Koma.create(owner_id: owner_id, koma_date: DateTime.strptime(koma_date, "%m/%d/%Y %H:%M"), koma_type: koma_type, prospect_name: prospect_name, memo: memo)
        ret =  {result: true, id: data["id"], owner_id: data['owner_id'], koma_date: data['koma_date'], koma_type: data['koma_type'], prospect_name: data['prospect_name'], memo: data['memo'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Koma has been created successfully." }
        return ret
      end
      
      def update
        param_koma_id = params[:id]
        param_owner_id = params[:owner_id]
        param_koma_date = params[:koma_date]
        param_koma_type = params[:koma_type]
        param_prospect_name = params[:prospect_name]
        param_memo = params[:memo]
        ret = validate_koma_update
        if ret[:result]
          koma = Koma.find_by(id: param_koma_id)
          if koma == nil
            render json: {result: false, message: "Koma id: #{param_koma_id} cannot be found."}   
            return
          end
          ret = update_koma(koma, param_owner_id, param_koma_date, param_koma_type, param_prospect_name, param_memo) 
  
          render json: ret
        else
          render json: ret
        end
      end
    
      private def update_koma(data, owner_id, koma_date, koma_type, prospect_name, memo) 
        data.update(owner_id: owner_id, koma_date: DateTime.strptime(koma_date, "%m/%d/%Y %H:%M"), koma_type: koma_type, prospect_name: prospect_name, memo: memo)
        ret =  {result: true, id: data["id"], owner_id: data['owner_id'], koma_date: data['koma_date'], koma_type: data['koma_type'], prospect_name: data['prospect_name'], memo: data['memo'], created_at: data['created_at'], updated_at: data['updated_at'], message: "Koma has been updated successfully." }
        return ret
      end
      
      def destroy
        param_id = params[:id].to_i()
        data = Koma.find_by(id: param_id)
        if data == nil
          render json: {result: false, message: "Koma id: #{param_id} cannot be found."}    
          return
        end 
        data.destroy()
  
        render json: {restul: true, id: data['id'], message: "Koma has been deleted." }    
      end
    
      private def validate_koma_create(owner_id, koma_date, koma_type, prospect_name, memo)
        #TODO: add validation later
        return {result: true}
      end
    
      private def validate_koma_update
        #TODO: add validation later
        return {result: true}
      end
end
