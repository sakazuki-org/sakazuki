module Users
  class InvitationsController < Devise::InvitationsController
    before_action :accept_admin, only: %i[new create]

    def new
      super
    end

    def create
      super
    end

    private

    # 招待メールを送れるのはadmin限定とする
    def accept_admin
      return if current_user.admin

      redirect_to(root_url, status: :see_other, alert: t(".permission_denied"))
    end
  end
end
