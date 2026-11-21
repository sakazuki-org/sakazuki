import eslint from "@eslint/js"
import globals from "globals"
import stylistic from "@stylistic/eslint-plugin"
import tseslint from "typescript-eslint"
import jsdoc from "eslint-plugin-jsdoc"
import eslintConfigPrettier from "eslint-config-prettier/flat"

export default tseslint.config(
  // 対象ファイル
  { files: ["**/*.{js,mjs,cjs,ts}"] },

  // ブラウザ環境を有効化
  { languageOptions: { globals: globals.browser } },

  // 必要ないインラインディレクティブをエラーにする
  {
    linterOptions: {
      reportUnusedDisableDirectives: "error",
      reportUnusedInlineConfigs: "error",
    },
  },

  // ESLintコアの設定
  eslint.configs.recommended,

  // @stylistic/eslint-pluginの設定
  stylistic.configs.all,

  // typescript-eslintの設定
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    plugins: {
      "@typescript-eslint": tseslint.plugin,
    },

    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        projectService: true,
      },
    },

    rules: {
      // 未使用変数はアンダーバー始まりにする
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          varsIgnorePattern: "^_",
          argsIgnorePattern: "^_",
        },
      ],
      // 型のインポートにはimport type構文を使う
      "@typescript-eslint/consistent-type-imports": "error",
      // interfaceを禁止し、typeを使う
      "@typescript-eslint/consistent-type-definitions": ["error", "type"],
    },
  },

  // typescript-eslintを使いつつJavaSciprtファイルに対応するために必要
  {
    files: ["**/*.{js,mjs,cjs}"],
    extends: [tseslint.configs.disableTypeChecked],
  },

  // eslint-plugin-jsdocの設定、doc系は報告レベルを警告にする
  jsdoc.configs["flat/contents-typescript"],
  jsdoc.configs["flat/logical-typescript"],
  jsdoc.configs["flat/recommended-typescript"],
  jsdoc.configs["flat/stylistic-typescript"],
  {
    rules: {
      // コメントブロックと関数の間に空行をいれない
      "jsdoc/lines-before-block": "off",
      // 文章とタグの間に空行を1行いれる
      "jsdoc/tag-lines": ["warn", "any", { startLines: 1 }],
    },
  },

  // eslint-config-prettierの設定
  eslintConfigPrettier,
)
