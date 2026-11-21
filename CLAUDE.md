# CLAUDE.md

このファイルはこのリポジトリで作業する Claude Code (claude.ai/code) への指示をまとめたものです。

## 指示

常に日本語を使ってください。

## プロジェクトの概要

SAKAZUKI は Rails で作った日本酒の在庫管理アプリです。
手持ちの日本酒を記録し、定量と定性の両面で飲んだ感想を残し、在庫を検索し、複数のユーザーで共有できます。
画像は AVIF 形式に圧縮して Cloudinary にアップロードします。

## 技術スタック

- バックエンド: Rails 8.1、Ruby 4.0（正確なバージョンは `Gemfile.lock` と `.ruby-version`）
- データベース: PostgreSQL >= 18
- フロントエンド: Hotwire（Turbo と Stimulus）、Bootstrap 5、esbuild（jsbundling-rails）でバンドルする TypeScript、Sass（cssbundling-rails）。Propshaft が `app/assets/builds/` から配信する
- 認証: Devise（invitable、confirmable、lockable、trackable を使用）
- 画像のアップロード: CarrierWave と Cloudinary（AVIF に圧縮）
- 検索: Ransack による全文検索
- ページネーション: Kaminari
- テスト: RSpec、FactoryBot、Capybara、Playwright（capybara-playwright-driver）
- コード品質: RuboCop、ERB Lint、Brakeman、ESLint、Prettier、Stylelint、Markuplint

## 開発用のコマンド

### セットアップ

```bash
# 依存パッケージをインストールする
bundle install
corepack enable && yarn install
yarn run playwright install chromium  # js: true を付けた system spec 用

# .env を用意する
cp dotenv.example .env
# .env に PostgreSQL の認証情報を書く

# データベースを用意する
bundle exec rails db:prepare
bundle exec rake parallel:setup  # 並列テスト用

# 管理者ユーザーを作る（必要なら先に db/seed.rb を編集する）
bundle exec rails db:seed

# JS と CSS の監視つきでサーバーを起動する（Procfile.dev）
bin/dev
# サーバーだけを起動する場合（アセットは再ビルドされない）: bundle exec rails server
# http://localhost:3000/ を開く
# 初期のログイン: example@example.com / rootroot
```

### テストの実行

```bash
# すべてのテストを実行する
bundle exec rspec

# ファイルを指定して実行する
bundle exec rspec spec/models/sake_spec.rb

# 行番号を指定して実行する
bundle exec rspec spec/models/sake_spec.rb:42

# 並列で実行する
bundle exec rake parallel:spec

# カバレッジも取る（coverage/ に出力する）
bundle exec rspec
```

### リントとコード品質

```bash
# すべてのチェックを実行する（CI と同等のチェック）
yarn run lint
# または: ./cli-scripts/run-all-checks.sh

# リンターを個別に実行する:
yarn run lint:eslint          # JavaScript
yarn run lint:eslint:fix      # JavaScript を自動修正
yarn run lint:tsc             # TypeScript の型チェック
yarn run lint:prettier        # フォーマットのチェック
yarn run lint:prettier:fix    # フォーマットを自動修正
yarn run lint:markdownlint    # Markdown
yarn run lint:stylelint       # CSS/SCSS
yarn run lint:stylelint:fix   # CSS/SCSS を自動修正
yarn run lint:markuplint      # HTML/ERB のマークアップ

bundle exec rubocop                              # Ruby
bundle exec rubocop -a                           # Ruby を自動修正
bundle exec rubocop --config .rubocop-erb.yml    # ERB
bundle exec erb_lint --lint-all                  # ERB lint
bundle exec brakeman --no-pager --run-all-checks # セキュリティ
```

### アセットのビルド

```bash
# JavaScript をビルドする
yarn run build

# CSS をビルドする
yarn run build:css

# 分析用のメタファイルを生成する
yarn run build:metafile
```

### Docker での開発

```bash
# イメージをビルドする
docker compose build --build-arg RUBY_VERSION=$(cat .ruby-version)

# データベースを用意する
docker compose run --rm web bundle exec rails db:prepare
docker compose run --rm web bundle exec rake parallel:setup
docker compose run --rm web bundle exec rails db:seed

# コンテナを起動する
docker compose up

# コンテナ内でテストを実行する
docker compose exec web bundle exec rspec
```

## コードの構成

### 主なモデル

Sake（`app/models/sake.rb`）: 日本酒の1本を表す中心のモデルです。日本酒に固有の属性を多く持ちます。

- 瓶の状態: `bottle_level` の enum（sealed/opened/empty）。`opened_at` と `emptied_at` は `BottleStateTimestampable` concern が設定する（自動では設定されない。後述の Concerns を参照）
- 酒の仕様: `tokutei_meisho`（特定名称）、`nihonshudo`（日本酒度）、`sando`（酸度）、`seimai_buai`（精米歩合）、`alcohol` など
- 製造の情報: `kura`（酒蔵）、`todofuken`（都道府県）、`genryomai` と `kakemai`（米の品種）、`kobo`（酵母）、`moto`（酒母）、`hiire`（火入れ）
- テイスティングの記録: `aroma_value`、`taste_value`、`rating`、`aroma_impression`、`taste_impression`
- 画像のアップロードのために `Photo` モデルと関連づける
- Ransack の独自エイリアス `all_text` で全文検索する
- ビジネスロジック: `alcohol_stock()` は在庫の合計を計算し、`new_arrival?` は新入荷かを判定し、`selling_price()` は1合あたりの価格を計算する

User（`app/models/user.rb`）: Devise で認証し、confirmable、lockable、timeoutable、trackable、invitable をすべて有効にしています。管理者は admin フラグで区別します。

Photo（`app/models/photo.rb`）: `ImageUploader`（`app/uploaders/`）をマウントします。
Cloudinary（AVIF への変換）を使うのは `config.x.cloudinary_enabled` が true のとき（本番）だけで、開発とテストではファイルをローカルに保存します。
ビューは `Photo#cl_reference` を `cl_image_path` に渡すので、どちらのモードでも同じコードで動きます。

### コントローラー

SakesController（`app/controllers/sakes_controller.rb`）: CRUD を受け持つ主なコントローラーです。
一覧の検索は `SakesSearch` concern に、写真の追加と削除は `SakesPhotos` concern にあります（どちらも `app/controllers/concerns/`）。
写真は Sake のレコードを保存したあとに別に保存します（`sake_params.except(:photos)`）。
追加の UI のために、独自の collection ルート `menu` を持ちます。

認証: 登録、招待、確認の Devise コントローラーを `app/controllers/users/` でカスタマイズしています。
確認メールとアンロックメールの再送ルートは、`config/routes.rb` で意図して無効にしています。

### フロントエンドの構成

JavaScript: 重い JavaScript フレームワークを使わず、Hotwire（Turbo Rails と Stimulus）で SPA に近い操作感を出します。
`yarn run build` は `app/javascript/` の直下にある各ファイルを別々のエントリーとしてバンドルします（主なものは `application.js`）。
コントローラーとモジュールは TypeScript で書き、`yarn run lint:tsc` で型チェックします。

Stimulus のコントローラー: 画面を操作する部品のコントローラーを `app/javascript/controllers/` に置きます。

独自の JavaScript モジュールは次のとおりです。

- `taste_graph/`: 味の傾向のグラフ（Chart.js）
- `completion/`: 入力の補完
- `simple_lightbox/`: 画像のライトボックス

CSS: Bootstrap 5 と、`app/assets/stylesheets/` にある独自の SCSS を Sass でコンパイルします。

### ローカライズ

アプリは主に日本語で（`config.i18n.default_locale = :ja`）、タイムゾーンは東京です。
ロケールファイルは `config/locales/**/*.ja.{rb,yml}` にあります。
enum とモデルの日本語訳には `enum_help` と `rails-i18n` を使います。

### テストの方針

RSpec はファイルの場所から spec の種類を推定します。使っているヘルパーは次のとおりです。

- request spec と system spec 向けの Devise の統合ヘルパー
- テストデータ用の FactoryBot（ファクトリーは `spec/factories/`）
- system spec 用の Capybara。標準は `rack_test` で、`js: true` を付けると Playwright 経由のヘッドレス Chromium で動く
- JS のテストを安定させるため、`spec/support/capybara.rb` で `data-testid` を探す `find(:test_id, ...)` と `wait_for_page`、`wait_for_alert` を追加している
- カバレッジ用の SimpleCov（`coverage/` に出力し、CI 向けに Cobertura 形式でも出す）
- system spec 向けの独自ヘルパー `SignIn`
- 時刻に依存するテスト向けの ActiveSupport::Testing::TimeHelpers

### 開発中のメール

開発環境では、`letter_opener_web` gem により `http://localhost:3000/letter_opener` でメールを確認できます。

## 押さえておくパターン

### Concerns

モデルの concern は `app/models/concerns/` にあります。

- `BottleStateTimestampable`: `bottle_level` の変化から `opened_at` と `emptied_at` を設定する。コールバックは持たない。`SakesController` と同じように、`initialize_bottle_state_timestamps`（create のあと）と `update_bottle_state_timestamps`（update のあと）を明示的に呼ぶ必要がある。どちらも内部でもう一度 `save!` を実行する

### Ransack のセキュリティ

セキュリティの問題を防ぐため、各モデルは `ransackable_attributes` と `ransackable_associations` で、検索してよい属性と関連を明示的に許可しています。

### Bootstrap のエラー表示

`config/application.rb` の独自の `field_error_proc` が、バリデーションエラーのあるフォーム項目に Bootstrap の `is-invalid` クラスを付けます。

### プレフィックス付きの enum

モデルの enum はメソッド名の衝突を避けるため `:prefix` オプションを使います（`namanama` ではなく `hiire_namanama` など）。
例外は `bottle_level` で、述語メソッドにプレフィックスが付きません（`sealed?`、`opened?`、`empty?`）。

## 開発時の注意

- Node.js のバージョンは `.node-version` で管理する（22 以上が必要）
- Ruby のバージョンは `.ruby-version` にある
- Yarn 4.7.0 を使う（`packageManager` フィールドで設定し、`corepack enable` で有効にする）
- 開発には libvips が必要（画像処理のため）
- 並列テスト用のデータベースは `parallel:setup` タスクで用意する
- Sake モデルにはバリデーションが多いので、属性を変えるときは注意する
- Google AdSense を組み込める（.env で設定する）
- コミットメッセージは `Type: summary` か `Type(scope): summary` の形で書く。Type には `Add`、`Update`、`Fix`、`Build(deps)` などを使う

## デプロイ

本番へのデプロイ手順は [デプロイの wiki](https://github.com/momocus/sakazuki/wiki/Deployment) にあります。
Fly.io にデプロイできます（`fly.toml` を参照）。

## Ruby バージョンアップ

- .ruby-version のバージョンを上げる
- Dockerfile の `ARG RUBY_VERSION` のバージョンを上げる
- `bundle install` で Gemfile.lock を更新する
- GitHub Actions の check/test で使っている ruby-setup のバージョンを上げる

## Rails バージョンアップ

[Rails ガイド - 一般的なアドバイス](https://railsguides.jp/upgrading_ruby_on_rails.html#%E4%B8%80%E8%88%AC%E7%9A%84%E3%81%AA%E3%82%A2%E3%83%89%E3%83%90%E3%82%A4%E3%82%B9) に従う

- Gemfile で指定した rails バージョンを上げる
- アップデートタスクを実行する
  - このとき、Rails が自動生成するコメントやデフォルト値は最新に追従する
  - Rails 自動生成デフォルトの後ろに SAKAZUKI のカスタマイズな値を追加する
  - 最後に Rubocop によるフォーマットをかける
- `config/initializers/new_framework_defaults_X_Y.rb` をすべて消しても動くようにする
- `config/initializers/new_framework_defaults_X_Y.rb` を削除し、`config.load_defaults` を新しいバージョンにセットする
