# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' },
#                          { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(
  email: "example@example.com",
  password: "rootroot",
  admin: true,
  # HACK: confirmed_atカラムに値が入っていれば、deviseが認証済みと判断する
  confirmed_at: Time.current,
)

load(Rails.root.join("db/seeds/development.rb")) if Rails.application.config.x.sake_seeds_enabled
