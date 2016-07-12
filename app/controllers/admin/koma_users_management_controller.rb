class Admin::KomaUsersManagementController < AdminApplicationController
  http_basic_authenticate_with name: "admin", password: "password"
  def show
     render template: "admin/koma_users_management/show"
   end
end
