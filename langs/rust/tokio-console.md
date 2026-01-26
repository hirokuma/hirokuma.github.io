---
layout: record
title: "tokio-console"
tags:
  - rust
daily: false
date: "2026/01/26"
---

`tokio::spawn()` でタスクを立ち上げている状態を目視したいときに tokio-console を使うことができる。

## tokio-console v0.5.0

* [tokio-rs/console: a debugger for async rust!](https://github.com/tokio-rs/console)

### アプリインストール

`cargo install` でインストールできる。

* [tokio-rs/console: a debugger for async rust!](https://github.com/tokio-rs/console?tab=readme-ov-file#running-the-console)

```shell
$ cargo install --locked tokio-console
```

### ソースコードの対応

観測したいアプリ側にも対応が必要。

#### ビルドオプション

`.cargo/config.toml` に設定して `cargo build` するか変数を使って `RUSTFLAGS="--cfg tokio_unstable" cargo build` するかでビルドする。

```toml
[build]
rustflags = ["--cfg", "tokio_unstable"]
```

#### `console_subscriber`

特にログシステムを使っていないなら `main()` の最初辺りに1行書いておけばよい。

```rust
console_subscriber::init();
```

Global subscriber が既に設定されていると2番目以降に設定しようとすると panic が起きる。
例えば `tracing_subscriber` を使う場合だ。  
そういうときは `console_subscriber::spawn()` で layer を取ってきて `.with()` で追加するとよいそうだ。
同じ高さに別のフィルタを設定すると打ち消されてtokio-consoleアプリに何も出てこないことがあるので注意だ。
そういうフィルタは `tracing_subscriber::fmt::layer()` の下にぶら下げると良いらしい。あまり理解していないがそれで動いた。

* [Adding the Console Subscriber](https://docs.rs/console-subscriber/latest/console_subscriber/#adding-the-console-subscriber)

## 他ページ参照

* [rust: tokio::broadcast と tokio::mpsc の recv はちょっと違う - hiro99ma blog](https://blog.hirokuma.work/2025/11/20251128-rst.html)
