# Context Auto-Detection Rules

Code review で変更ファイルのコンテキストを自動判定し、適用すべき非機能要件（NFR）基準を決定するルール。

## Stage 1: File Pattern Classification

変更されたファイルのパス・拡張子からカテゴリを仮判定する。1 つのファイルが複数カテゴリに該当する場合はすべて採用する。

| Category | File Patterns |
|---|---|
| **API / Backend** | `*.controller.*`, `*.service.*`, `*.repository.*`, `*.resolver.*`, `routes/`, `handlers/`, `api/`, `server.*` |
| **Web Frontend** | `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `*.astro`, `components/`, `pages/`, `app/`, `*.css`, `*.scss`, `*.module.css` |
| **Infrastructure** | `Dockerfile`, `docker-compose.*`, `*.tf`, `*.hcl`, `helm/`, `k8s/`, `.github/workflows/`, `*.yaml`（CI/CD context）, `Makefile` |
| **Library / SDK** | `packages/*/src/`, `lib/`, `src/index.*`（export definitions）, `*.d.ts` |
| **Data / DB** | `migrations/`, `*.sql`, `schema.*`, `*.prisma`, `*.entity.*`, `seeds/`, `fixtures/` |

## Stage 2: Project Exploration

Stage 1 の仮判定を補強するため、プロジェクト内のファイルを Read / Glob / Grep で探索する。

| Exploration Target | Tool & Pattern | Detection Signal |
|---|---|---|
| **パッケージ定義** | Read: `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` | フレームワーク検出（Next.js, Express, FastAPI 等）、i18n / a11y ライブラリの有無 |
| **TypeScript / Lint 設定** | Read: `tsconfig.json` / `.eslintrc*` | a11y プラグイン（eslint-plugin-jsx-a11y 等）、strict mode |
| **環境変数** | Read: `.env.example` | 外部サービス依存、環境変数の存在 |
| **Logger** | Grep: `winston`, `pino`, `bunyan`, `log4j`, `logrus`, `slog`, `tracing` | Observability パターンの検出 |
| **i18n 設定** | Glob: `locales/`, `i18n.*`, `messages/`, `translations/` | i18n 導入状況 |
| **CI/CD 設定** | Glob: `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml` | デプロイパイプライン、ヘルスチェック |
| **ORM / DB** | Grep: `prisma`, `typeorm`, `sequelize`, `sqlalchemy`, `gorm`, `diesel` | Data Privacy / Scalability の関連度 |
| **API 定義** | Glob: `openapi.*`, `swagger.*`, `*.proto`, `*.graphql` | API 互換性の必要性 |
| **ヘルスチェック** | Grep: `/health`, `/ready`, `healthCheck`, `health_check` | Operability 実装状況 |

## Reinforcement Rules

Stage 1 の仮判定を Stage 2 の探索結果で補強・追加する。

1. **Stage 1 → Stage 2 の流れ**: Stage 1 で仮判定したカテゴリを Stage 2 で裏付け、必要に応じて追加カテゴリを付与する
2. **i18n ライブラリ未導入**: i18n 関連ライブラリが `package.json` 等に存在しない場合、i18n 基準を「必須」から「推奨（recommendation）」レベルに緩和する
3. **Logger 未導入 + API カテゴリ**: Logger ライブラリが検出されなくても、API / Backend カテゴリに該当する場合は Observability 基準を適用する（導入提案として指摘）

## Category → NFR Criteria Mapping

検出されたカテゴリに基づき、適用する非機能要件基準を決定する。

| NFR | API | Frontend | Infra | Library | Data |
|---|---|---|---|---|---|
| NF1. Observability | ✅ | — | ✅ | — | — |
| NF2. Scalability | ✅ | — | ✅ | — | ✅ |
| NF3. Accessibility | — | ✅ | — | — | — |
| NF4. i18n | — | ✅ | — | — | — |
| NF5. API Compatibility | ✅ | — | — | ✅ | — |
| NF6. Operability | ✅ | — | ✅ | — | — |
| NF7. Data Privacy | ✅ | — | — | — | ✅ |

## Scope Output Addition

Phase 1（スコープ分析）の出力に以下を追加する。

```
- Context: [detected categories]
- NFR criteria: [NF1, NF3, ...] (applied based on context)
- Project signals: [e.g., "Next.js detected", "i18n not configured", "pino logger found"]
```

### 出力例

```
- Context: API / Backend, Data / DB
- NFR criteria: NF1 (Observability), NF2 (Scalability), NF5 (API Compatibility), NF6 (Operability), NF7 (Data Privacy)
- Project signals: "Express.js detected", "prisma ORM found", "pino logger found", "no health check endpoint detected"
```
