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

[tracing_subscriber](./subscriber.md)は [Available logging implementations](https://docs.rs/log/latest/log/#available-logging-implementations) には載っていないが、
`log` クレートでも使える。

* [log Compatibility](https://docs.rs/tracing/latest/tracing/#log-compatibility)
* [For log Users](https://docs.rs/tracing/latest/tracing/#for-log-users)
* [deep wiki](https://deepwiki.com/search/tracingsubscriber-log_d982ec35-4e8a-4809-9fb7-572a2ed3bb95?mode=fast)

```rust
use tracing::*;
```

## 他ページ参照

* [tracing_subscriber](./subscriber.md)
