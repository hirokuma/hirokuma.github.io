---
layout: record
title: "tracing_subscriber"
tags:
  - rust
daily: false
date: "2026/01/26"
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

## `RUST_LOG`

環境変数 `RUST_LOG` でログレベルの設定ができる。  
これは `tracing_subscriber` が行っている解釈なので、他のログシステムはまた違う。

* `=` 無しで書いたレベルは全体のレベル(`RUST_LOG=debug`)
* `::` 無しで書いたレベルは特定のクレートのレベル(`RUST_LOG=debug,libp2p=trace`)
* `::` 有りで書いたレベルは特定のモジュールのレベル(`RUST_LOG=debug,libp2p=trace,myapp::network=info`)

他にも色々できる。

* [deep wiki](https://deepwiki.com/search/_eee534ac-67e4-400a-832b-0c6063249bbc?mode=fast)

### 必ずしも `RUST_LOG` が使われるとは限らない

`tracing_subscriber` の `.from_env_lossy()` を使うと環境変数 `RUST_LOG` を読み取ってくれる。
ということは `.from_env_lossy()` を使っていないと読み取ってくれないということである。

* [DEFAULT_ENV](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html#associatedconstant.DEFAULT_ENV)

また `.from_env_lossy()` は基本的にフィルタの並びの最後に使うものになっていて自分の設定と織り交ぜにくい時がある。
そういうときは自分で設定を作って `.parse_lossy()` で `EnvFilter` にしてから `.with(filter)` のようにして使うと良いと思う。

* [parse_lossy](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.Builder.html#method.parse_lossy)

開発中は一時的にログ出力を制限したかったり、しばらく同じ箇所の開発を続けるので実装で埋め込んでしまいたかったりするんじゃなかろうか。
そういうときに使うとよい。  
両方活かすための実装自体が結構面倒で、私は途中で投げ出して中途半端になってしまった。
ほどほどがよいのだろう。

## 日記参照

* [rust: tracing_subscriber ログあれこれ - hiro99ma blog](https://blog.hirokuma.work/2025/12/20251216-rst.html)
* [rust: tracing_subscriber は RUST_LOG より実装が優先 - hiro99ma blog](https://blog.hirokuma.work/2025/12/20251209-rst.html)
