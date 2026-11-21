# This rake task was added by annotate_rb gem.

# Gem.loaded_specs を使うのは rake ロード時点では environments/*.rb が
# まだ評価されておらず、config.x.* の feature flag では分岐できないため。
# annotaterb は development グループの gem なので、bundle install --without
# development された環境では loaded_specs に存在せずスキップされる。
if Gem.loaded_specs.key?("annotaterb") && ENV["ANNOTATERB_SKIP_ON_DB_TASKS"].nil?
  require "annotate_rb"

  AnnotateRb::Core.load_rake_tasks
end
