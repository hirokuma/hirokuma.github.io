---
layout: record
title: "tracing_subscriber"
tags:
  - rust
daily: false
date: "2026/01/23"
---

## tracing_subscriber

```toml
log = "0.4.29"
tokio = { version = "1.48.0", features = ["macros", "rt-multi-thread"] }
tracing = "0.1.44"
tracing-subscriber = { version = "0.3.22", features = ["env-filter", "json"] }
```

### 設定

```rust
// https://deepwiki.com/search/withlevel_fe927987-cab6-4a10-8e71-3e569cbc284b?mode=fast
tracing_subscriber::fmt::Subscriber::builder()
    .with_ansi(true) // 色を付けるかどうか
    .with_file(true) // ファイル名を出力するかどうか
    .with_level(true) // ログレベルを出力するかどうか
    .with_line_number(true) // 行番号を出力するかどうか
    .with_span_events(tracing_subscriber::fmt::format::FmtSpan::NONE) // spanをどうするか
    .with_target(false) // モジュールパスなどを出力するかどうか
    .with_thread_ids(false) // Thread IDを出力するかどうか
    .with_thread_names(true) // Thread名を出力するかどうか
    .with_max_level(tracing::Level::ERROR) // ログ出力する最大レベル(これより下は出力されない)
    .with_timer(tracing_subscriber::fmt::time::Uptime::default()) // 時間のフォーマット
    .with_writer(std::io::stderr) // 出力先(デフォルトはstdout)
    .without_time() // 時間を表示しない
    .init();
```

## メモ

* [rust: tracing_subscriber ログあれこれ - hiro99ma blog](https://blog.hirokuma.work/2025/12/20251216-rst.html)
