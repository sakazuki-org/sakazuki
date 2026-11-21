# Contribution guide

- GitHub の Issue と Pull Request にて受け付けています。
- 現状では少数開発のため、受け入れ基準は明確化されていません。
- プロジェクトのセットアップ方法は README.md を参照してください。

## Issues

- バグレポートや機能リクエストを Issue として提出できます。
- テンプレートがあるため、それに従って項目を埋めてください。

## Pull Requests

- この Pull Request によって解決される Issue への参照を含めてください。
- テストと Lint に合格していることを確認してください。GitHub Actions により自動化されています。
  - 手動でチェックを実行する場合は `yarn lint` を使用してください。
  - 他の手動チェックコマンドについては package.json の scripts を参照してください。
- Pull Request のマージにはレビュワー一人以上の承認が必要です。
