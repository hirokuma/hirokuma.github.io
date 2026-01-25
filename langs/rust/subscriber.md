---
layout: record
title: "tracing_subscriber"
tags:
  - rust
daily: false
date: "2026/01/23"
---

## tracing_subscriber

* [tokio-rs/tracing: Application level tracing for Rust.](https://github.com/tokio-rs/tracing/search?l=shell)
* [tokio-rs/tracing | DeepWiki](https://deepwiki.com/tokio-rs/tracing)

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
    .with_file(true) // ファイル名を出力するかどうか(フルパス)
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

* `with_source_location(bool)`
  * `with_file(bool)` と `.with_line_number(bool)` を同時に設定する
* `FormatEvent` を使ったカスタマイズが可能
  * [deep wiki](https://deepwiki.com/search/withfile_06d63fd0-a59b-42ac-97c2-95210e76e49b?mode=fast)

### `RUST_LOG`

環境変数 `RUST_LOG` でログレベルの設定ができる。  
これは `tracing_subscriber` が行っている解釈なので、他のログシステムはまた違う。

* `=` 無しで書いたレベルは全体のレベル(`RUST_LOG=debug`)
* `::` 無しで書いたレベルは特定のクレートのレベル(`RUST_LOG=debug,libp2p=trace`)
* `::` 有りで書いたレベルは特定のモジュールのレベル(`RUST_LOG=debug,libp2p=trace,myapp::network=info`)

他にも色々できる。

* [deep wiki](https://deepwiki.com/search/_eee534ac-67e4-400a-832b-0c6063249bbc?mode=fast)

## メモ

* [rust: tracing_subscriber ログあれこれ - hiro99ma blog](https://blog.hirokuma.work/2025/12/20251216-rst.html)
