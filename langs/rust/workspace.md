---
layout: record
title: "cargo workspace"
tags:
  - rust
daily: false
date: "2026/01/10"
---

`cargo new` で1つのプロジェクトを作る。  
そういう作り方ではなく、ワークスペースを作って複数のプロジェクトを持つこともできる。

* [rust: cargo の workspace - hiro99ma blog](https://blog.hirokuma.work/2025/11/20251112-rst.html)

といっても、`cargo workspace` だったり `cargo XXX --workspace` のようなコマンドがあるわけではない。
昔はあったようだが、少なくとも今(2026/01/10)はないようだ。  
なのでワークスペースを使うときは手動で `Cargo.toml` を編集することが多い。

## よいこと

おそらくメリットは、トップディレクトリに置いた `Cargo.toml` の `[dependencies]` を共有してバージョンを合わせられるところと、
ライブラリを複数持ちたいけれどもそれぞれ別のプロジェクトにするのは面倒なのが軽減される
というところではなかろうか。

ワークスペース内のライブラリは相対パスで `[dependencies]` に書くことができる。
これはワークスペースじゃなくてもできるのかも？

## 使いたいかどうか

ワークスペースを使いたいかどうかなので、使いたくなければそれでよいと思う。  
ライブラリも、他でも使いたいからライブラリにするという側面もあるだろう。
そうなると同じリポジトリにあっても使いづらいだろうから別のリポジトリにするだろう。  
最初はワークスペースで作りながら、最後に別のリポジトリにするというやり方もあるだろう。

## おおよその使い方

[Workspaces - The Cargo Book](https://doc.rust-lang.org/cargo/reference/workspaces.html)

### ワークスペースにするディレクトリを作ってCargo.tomlを置く

`cargo` コマンドは使わずに、普通にディレクトリを作って `Cargo.toml` を置く。  
内容はこんな感じか。

```toml
[workspace]
resolver = "3"

members = []
default-members = []
```

[resolver](https://doc.rust-lang.org/cargo/reference/resolver.html#resolver-versions) は最近は "3" のようだからそうしているだけだ。  
[workspace.dependencies](https://doc.rust-lang.org/cargo/reference/workspaces.html#the-dependencies-table) は自分で編集することになるだろう。

### パッケージの追加

通常のパッケージ作成と同じくワークスペースの中で `cargo new` する(追加するからと `cargo add` としないよう注意)。  
ただ、オプションを付けないと `.git/` も作ってしまうので、作りたくないなら `--vcs none` をつける。  
ワークスペースの中で実行するとこのようにワークスペースに追加したというメッセージが出力される。

```shell
$ cargo new abc --vcs none
    Creating binary (application) `abc` package
      Adding `abc` as member of workspace at `/home/hirokuma/rust/workspace`
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
```

`Cargo.toml` の members に追加されている。

```toml
[workspace]
resolver = "3"

members = ["abc"]
default-members = []
```

特定のパッケージをビルドしたいなら `-p` をつけてパッケージを指定する。

```shell
$ cargo build -p abc
   Compiling abc v0.1.0 (/home/hirokuma/rust/workspace/abc)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.97s
```

全部なら `cargo build --all`。  
いつもビルドするパッケージが決まっているなら default-members に列挙しておくと `cargo build` だけで済むので楽だろう。

```toml
[workspace]
resolver = "3"

members = ["abc"]
default-members = ["abc"]
```

```shell
$ cargo build
   Compiling abc v0.1.0 (/home/hirokuma/rust/workspace/abc)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.33s
```

### dependenciesの追加

ワークスペースのトップディレクトリにある `Cargo.toml` にクレートを追加するコマンドはない。
その代わり、どのパッケージにクレートを追加するか指定する `-p` が使用できる(ワークスペースのパッケージが1つしかない場合は `-p` がなくてもよいみたい)。

```shell
$ cargo add anyhow -p abc
```

`cargo add` して dependencies に追加される `Cargo.toml` はそのパッケージに対してだけである。
しかし `Cargo.lock` はワークスペース直下にしか存在しない。
別のところで作成していたパッケージをワークスペースに移動させると `Cargo.lock` も残ったままになるが
おそらくそのファイルは更新されないままになる。  
更新されても困るので、ワークスペースのトップディレクトリ以外の `Cargo.lock` は削除したほうがよいと思う。
私はよくわからないので、とりあえず全部 `Cargo.lock` を削除してビルドし直した。

### workspace.dependenciesに移動

まずパッケージの `Cargo.toml` から移動させたい dependencies を選ぶ。  
行コピーしてワークスペースの `Cargo.toml` にある `[workspace.dependencies]` に追加。  
パッケージの `Cargo.toml` は `workspace = true` のような感じにしておく。

#### 例

パッケージの `Cargo.toml` がこうだったとき、

```toml
[dependencies]
anyhow = "1.0.100"
```

これをワークスペースの `Cargo.toml` にはこう。

```toml
[workspace]
resolver = "3"

members = ["abc"]
default-members = ["abc"]

[workspace.dependencies]
anyhow = "1.0.100"
```

パッケージの `Cargo.toml` はこう。

```toml
[dependencies]
anyhow.workspace = true
```
