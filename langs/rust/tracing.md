---
layout: record
title: "rust: tracingログのサンプル"
tags:
  - rust
daily: false
create: "2026/07/06"
date: "2026/07/06"
---

## サンプル集

`tracing`をどう使うとどう出力されるのか確認するのが面倒なことがしばしばある。
サンプルをいくつか残しておこう。

```toml
[package]
name = "hello"
version = "0.1.0"
edition = "2024"

[dependencies]
thiserror = "2.0.18"
tracing = "0.1.44"
tracing-subscriber = "0.3.23"
```

### instrument

{% raw %}

```rust
use std::{error::Error, result::Result};

use tracing::*;

#[derive(thiserror::Error, Debug)]
pub enum DataStoreError {
    #[error("invalid header (expected {expected:?}, found {found:?})")]
    InvalidHeader { expected: String, found: String },
}

#[macro_export]
macro_rules! err_log {
    ($err_variant:expr) => {{
        let err = $err_variant;
        error!("{}", err);
        Err(err)
    }};
}

#[instrument]
fn opening2(msg: &str) {
    debug!("opening2: {}", msg);
}

#[instrument]
fn opening(msg: &str) {
    trace!("opening: {}", msg);
    opening2(msg);
}

#[instrument]
fn open(msg: &str) -> Result<(), DataStoreError> {
    warn!("open(): {}", msg);
    opening(msg);
    err_log!(DataStoreError::InvalidHeader {
        expected: "こうであってほしい".to_string(),
        found: "こうだった".to_string(),
    })
}

#[instrument]
fn main() {
    tracing_subscriber::fmt::Subscriber::builder()
        .with_file(true) // ファイル名を出力するかどうか(フルパス)
        .with_line_number(true) // 行番号を出力するかどうか
        .with_max_level(tracing::Level::TRACE) // ログ出力する最大レベル(これより下は出力されない)
        .init();

    info!("main()");
    open("みゃー").unwrap_or_else(|e| {
        error!("open error: {}", e);
        if let Some(err) = e.source() {
            error!("base error: {}", err);
        }
    });
}
```

{% endraw %}

#### instrument: そのまま実行

```log
2026-07-05T22:30:11.048711Z  INFO hello: src/main.rs:49: main()
2026-07-05T22:30:11.048795Z  WARN open{msg="みゃー"}: hello: src/main.rs:33: open(): みゃー
2026-07-05T22:30:11.048831Z TRACE open{msg="みゃー"}:opening{msg="みゃー"}: hello: src/main.rs:27: opening: みゃー
2026-07-05T22:30:11.048850Z DEBUG open{msg="みゃー"}:opening{msg="みゃー"}:opening2{msg="みゃー"}: hello: src/main.rs:22: opening2: みゃー
2026-07-05T22:30:11.048882Z ERROR open{msg="みゃー"}: hello: src/main.rs:35: invalid header (expected "こうであってほしい", found "こうだった")
2026-07-05T22:30:11.048913Z ERROR hello: src/main.rs:51: open error: invalid header (expected "こうであってほしい", found "こうだった")
```

#### instrument: mainから削除

`main()`の前にある`#[instrument]`を削除。  
変化無し。

```log
2026-07-05T22:31:52.570387Z  INFO hello: src/main.rs:48: main()
2026-07-05T22:31:52.570459Z  WARN open{msg="みゃー"}: hello: src/main.rs:33: open(): みゃー
2026-07-05T22:31:52.570481Z TRACE open{msg="みゃー"}:opening{msg="みゃー"}: hello: src/main.rs:27: opening: みゃー
2026-07-05T22:31:52.570493Z DEBUG open{msg="みゃー"}:opening{msg="みゃー"}:opening2{msg="みゃー"}: hello: src/main.rs:22: opening2: みゃー
2026-07-05T22:31:52.570510Z ERROR open{msg="みゃー"}: hello: src/main.rs:35: invalid header (expected "こうであってほしい", found "こうだった")
2026-07-05T22:31:52.570539Z ERROR hello: src/main.rs:50: open error: invalid header (expected "こうであってほしい", found "こうだった")
```

#### instrument: さらにopeningから削除

`main()`と`opening()`から`#[instrument]`を削除。

span出力から`opening{msg="みゃー"}`がなくなった。
`#[instrument]`はspanを定義するものなので、書いた関数をくぐるほど増えていく。
デフォルトでは関数名が使われるので、通った関数名を出力させるのによさそうだがうっとうしくもある。  
関数名を出力したかったら、非常に面倒だが`trace!()`で自分で関数名を書くのが確実で最小限になりそうだ。
せめて`func!()`のようなマクロがあればよかったのだが、ないのだ。

```log
2026-07-05T22:33:53.005297Z  INFO hello: src/main.rs:47: main()
2026-07-05T22:33:53.005373Z  WARN open{msg="みゃー"}: hello: src/main.rs:32: open(): みゃー
2026-07-05T22:33:53.005401Z TRACE open{msg="みゃー"}: hello: src/main.rs:26: opening: みゃー
2026-07-05T22:33:53.005422Z DEBUG open{msg="みゃー"}:opening2{msg="みゃー"}: hello: src/main.rs:22: opening2: みゃー
2026-07-05T22:33:53.005437Z ERROR open{msg="みゃー"}: hello: src/main.rs:34: invalid header (expected "こうであってほしい", found "こうだった")
2026-07-05T22:33:53.005462Z ERROR hello: src/main.rs:49: open error: invalid header (expected "こうであってほしい", found "こうだった")
```
