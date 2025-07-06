//---
title: "rust: ファイルの分割"
tags:
  - rust
date: "2025/07/06"
//---

## 勉強中

## 概要

プログラムを複数のファイルに分割したときの取り扱い方について。  
Cargoを使う前提とする。

## 参考

* [肥大化していくプロジェクトをパッケージ、クレート、モジュールを利用して管理する - The Rust Programming Language 日本語版](https://doc.rust-jp.rs/book-ja/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html)
* [Cargoのワークスペース - The Rust Programming Language 日本語版](https://doc.rust-jp.rs/book-ja/ch14-03-cargo-workspaces.html)

## クレート

コンパイルは「クレート」が最小単位となっている。

![image](images/crate.png)

[バイナリクレート](https://doc.rust-lang.org/cargo/reference/cargo-targets.html#binaries)と[ライブラリクレート](https://doc.rust-lang.org/cargo/reference/cargo-targets.html#library)の種類が生まれるのはパッケージのようにも思うが、細かく区別する必要もないだろう。  
バイナリクレートは`cargo new --bin`(`--bin`はデフォルトなのでなくてもよい)で作られるタイプで`src/main.rs`がエントリーポイントと思っていて良いだろう。  
ライブラリクレートは`src/lib.rs`を持つ。

`cargo add`はクレートを追加する[Manifestコマンド](https://doc.rust-lang.org/cargo/commands/cargo-add.html)で、空のクレートを追加するのではなく`Cargo.toml`に依存関係を追加するコマンドである。
「`Cargo.toml` Manifestファイル」と書いてあるので、Manifestコマンドは`Cargo.toml`に関するコマンドだろう。

## パッケージ

「パッケージ」は1つ以上のクレートを持つ。  
`cargo new`で作られるのはパッケージである。[packageコマンド](https://doc.rust-lang.org/cargo/commands/package-commands.html)という分類になっている。

![image](images/package.png)

ライブラリクレートは最大でも1つなので`src/lib.rs`があるかどうかでわかる。  
`Cargo.toml`では`[lib]`セクションでカスタマイズできる。

バイナリクレートも`src/main.rs`があるかどうかでわかるのだが、こちらは複数持つことができる。その場合は`src/bin/`にディレクトリを作って`main.rs`を置く。  
`src/main.rs`を持たずに`src/bin/*`に複数のディレクトリを作ってそれぞれに`main.rs`を持っても良い。  
`Cargo.toml`では`[[bin]]`セクションでカスタマイズできる。括弧が1つ多い。

