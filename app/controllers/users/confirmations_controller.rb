module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation?confirmation_token=abcdef
    # reconfirmable (メアド変更時の確認メール) の着地点としてのみ利用する。
    # token なし or 不正なリクエストはページの存在を伏せるため 404 を返す。
    def show
      raise(ActionController::RoutingError, "Not Found") if params[:confirmation_token].blank?

      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      raise(ActionController::RoutingError, "Not Found") if resource.errors.any?

      set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource) { redirect_to(after_confirmation_path_for(resource_name, resource)) }
    end
  end
end
