# 酒瓶の状態変化（封→開栓→空）に基づいて日時を管理するモジュール
# 仕様はIssueに
# https://github.com/momocus/sakazuki/issues/285
module BottleStateTimestampable
  extend ActiveSupport::Concern

  # 作成時の酒瓶状態に応じて、開栓日・空瓶日を設定する
  def initialize_bottle_state_timestamps
    self.opened_at = created_at unless sealed?
    self.emptied_at = created_at if empty?
    save!
  end

  # 酒瓶状態の変更に応じて、開栓日・空瓶日を更新する
  def update_bottle_state_timestamps
    case saved_change_to_attribute(:bottle_level)
    in [old, new]
      self.opened_at = updated_at if old == "sealed"
      self.emptied_at = updated_at if new == "empty"
    in nil
      return
    end
    save!
  end
end
