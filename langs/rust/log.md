---
layout: record
title: "ログ出力"
tags:
  - rust
daily: false
create: "2026/01/26"
date: "2026/05/30"
---

Rustでは、標準でしくみだけ用意しておき、実際の中身はそれぞれのライブラリに任せるということがしばしばある。
ログ出力もそうである。

## logクレート

標準と言っても`std`ではなく`log`クレートである。
rust-lang/log なので標準的なものといってよかろう。

* [log - Rust](https://docs.rs/log/latest/log/)

これはAPIを提供するだけで出力するには別のクレートを読み込む必要がある。

* [Available logging implementations](https://docs.rs/log/latest/log/#available-logging-implementations)

### 使い方

こう書いておくと `error!()`, `warn!()` `info!()`, `debug!()`, `trace!()` が使用できる。

```rust
use log::*;
```

## tracingクレート

`tracing`クレートにも同じように`error!`などのマクロがある。


[tracing_subscriber](./subscriber.md)は [Available logging implementations](https://docs.rs/log/latest/log/#available-logging-implementations) には載っていないが、`log` クレートでも使える。

* [log Compatibility](https://docs.rs/tracing/latest/tracing/#log-compatibility)
* [For log Users](https://docs.rs/tracing/latest/tracing/#for-log-users)
* [deep wiki](https://deepwiki.com/search/tracingsubscriber-log_d982ec35-4e8a-4809-9fb7-572a2ed3bb95?mode=fast)

```rust
use tracing::*;
```

## サンプル

```toml
[dependencies]
env_logger = "0.11.10"
log = "0.4.30"
tracing = "0.1.44"
tracing-subscriber = "0.3.23"
```

### logのみ

logのみでは何も出力されない。

```rust
use log::*;

fn main() {
    error!("エラーだ");
}
```

### log + env_logger

```rust
use log::*;

fn main() {
    env_logger::init();
    error!("エラーだ");
}
```

```log
[2026-05-29T23:49:26Z ERROR hello] エラーだ
```

### tracingのみ

tracingのみでは何も出力されない。

```rust
use tracing::*;

fn main() {
    error!("エラーだ");
}
```

### tracing + tracing_subscriber

```rust
use tracing::*;

fn main() {
    tracing_subscriber::fmt::init();
    error!("エラーだ");
}
```

```log
2026-05-29T23:51:21.286031Z ERROR hello: エラーだ
```

### env_logger + tracing_subscriber

Global loggerは複数設定できないので実行時エラーになる。

```rust
use log::*;

fn main() {
    env_logger::init();
    tracing_subscriber::fmt::init();
    error!("エラーだ");
}
```

```shell
Unable to install global subscriber: SetLoggerError(())
```

### log + tracing_subscriber

こちらは出力される。
ミリ秒以下の出力が多いので`tracing_subscriber`の内容だと思われる。

```rust
use log::*;

fn main() {
    tracing_subscriber::fmt::init();
    error!("エラーだ");
}
```

```log
2026-05-29T23:54:21.025413Z ERROR hello: エラーだ
```

### tracing + env_logger

この組み合わせは何も出力されない。

```rust
use tracing::*;

fn main() {
    env_logger::init();
    error!("エラーだ");
}
```

## 手軽に切り替えたい

`log`クレートに対しては`env_logger`も`tracing_subscriber`も使えるが、`tracing`クレートに対しては`env_logger`は対応されていない。
がんばればできるのかもしれないが、そう簡単そうでもなかった(たぶん)。

そういう運用がしたいというよりは、自分は`env_logger`でよいのだけどライブラリのいくつかが`tracing`でログを書いているからどうしよう、という場合だろう。
それならライブラリは`log`クレートの方で書いておくのが無難なのだが、ライブラリの方が`tracing`のように階層になっているログが欲しいということもあろう。

そんな感じでライブラリを書いているとちょっと悩ましくて、簡単に書き換えられるようにしたい。
ChatGPTに聞くと内部でre-exportする方式を考えてくれた。  
一括置換しても大したことはないのだろうが、せっかく`use`の順番も考えて書いてるのに、などということもあるだろう。

### Cargo.toml

`Cargo.toml`に自前の`features`を追加して`#[cfg()]`マクロで切り替えるのに使う。

```toml
[features]
default = ["log"]
log = []
tracing = []
```

### logging.rs

2択で切り替える。

```rust
#[cfg(feature = "tracing")]
#[allow(unused_imports)]
pub use tracing::{debug, error, info, trace, warn};

#[cfg(not(feature = "tracing"))]
#[allow(unused_imports)]
pub use log::{debug, error, info, trace, warn};
```

### 各ファイル

エントリーポイント？で`mod`して、`use`でうまいこと引き込めばよい。

```rust
mod logger;

use crate::logger::*;
```

## 他ページ参照

* [tracing_subscriber](./subscriber.md)
