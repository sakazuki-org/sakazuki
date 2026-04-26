module Users
  include ApplicationHelper

  class RegistrationsController < Devise::RegistrationsController
    before_action :redirect_to_root, only: %i[new create]

    # GET /resource/sign_up
    def new
      super
    end

    # POST /resource
    def create
      super
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    private

    def redirect_to_root
      redirect_to(root_url, status: :see_other, alert: t(".permission_denied"))
    end
  end
end
