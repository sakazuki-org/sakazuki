class SakeGachaController < ApplicationController
  # GET /sakes/gacha
  def show
    sake = Sake.where.not(bottle_level: :empty).order("RANDOM()").first
    if sake
      redirect_to(sake)
    else
      redirect_to(sakes_path, alert: t(".empty"))
    end
  end
end
