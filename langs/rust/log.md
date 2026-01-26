---
layout: record
title: "ログ出力"
tags:
  - rust
daily: false
date: "2026/01/26"
---

Rustでは、標準でしくみだけ用意しておき、実際の中身はそれぞれのライブラリに任せるということがしばしばある。
ログ出力もそうである。

## logクレート

標準と言っても `std` ではなく `log` クレートである。

* [log - Rust](https://docs.rs/log/latest/log/)

これはAPIを提供するだけで出力するには別のクレートを読み込む必要がある。

* [Available logging implementations](https://docs.rs/log/latest/log/#available-logging-implementations)

## 使い方

こう書いておくと `error!()`, `warn!()` `info!()`, `debug!()`, `trace!()` が使用できる。

```rust
use log::*;
```

### tracing::log

[tracing_subscriber](./subscriber.md)は Available logging implementations には載っていないが、
私の記憶では `log` クレートでも使えたように思う。  
ただ互換性の章があるし、`tracing_subscriber` を使いたいのは細かいログ制御を欲しているときでもあるので、
`main.rs` だけ `use tracing::*` でそれ以外を `use log::*` にするより `tracing` に統一したほうが無難かもしれない。

* [log Compatibility](https://docs.rs/tracing/latest/tracing/#log-compatibility)
* [For log Users](https://docs.rs/tracing/latest/tracing/#for-log-users)

```rust
use tracing::*;
```

## 他ページ参照

* [tracing_subscriber](./subscriber.md)
