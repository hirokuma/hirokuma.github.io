---
layout: record
title: "型変換"
tags:
  - rust
daily: false
date: "2025/11/15"
draft: true
---

## はじめに

Rust は型チェックが厳しいので、しばしば型変換が必要になる。

## おおよその名前ルール

標準ライブラリには名前のルールがある。  
それ以外でもこのルールに従っていると考えた方がよいだろう。

* [Naming - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/naming.html#ad-hoc-conversions-follow-as_-to_-into_-conventions-c-conv)

### `as_`

borrowed -> borrowed でコストも低い。

### `to_`

3パターンある。

#### borrowed -> borrowed

borrowed -> borrowed で `as_` に比べるとコストが高い。  
データのチェックをして大丈夫だったらキャストする場合など(例: `OsStr::to_str(&self) -> Option<&str>`)。

#### borrowed -> owned (non-Copy types)

変換先のメモリを作って borrowed のデータをコピーするなり変換するなり。  
元が borrowed なので non-Copy の意味は気にしなくてよいと思う。

#### owned -> owned (Copy types)

変換元が `Copy` トレイトを持っているので所有権を奪われないが、
その分コピーするコストが発生するということだろう。  
borrowed -> owned と同じくらいのコストがかかるのかもしれないが、
`Copy` トレイトによる複製が行われてから変換するのと、
値を変換しながらとでは後者の方がコストが低いように思う。
もし `Copy` トレイトの処理が必ず行われるならプリミティブ型のように 
複製のコストが低い型にしかないかもしれない。

### `into_`

owned -> owned (non-Copy types) で、元の所有権を奪うことになる。  
その分、元のデータを使い回すことでコストが低くできるのかもしれない。  
呼び出し元で所有権を奪われないための処理をするかどうかの選択ができると考えれば良いか。

`to_` は型変換以外でも英語的な意味(degree から radian に変換、など)で使うかもしれないが、
`into_` はなんとなく型変換のみで使った方がよさそうな気がする(個人の感想)。

## 参照

* [rust: 別の型に変換するルールを分かりたい - hiro99ma blog](https://blog.hirokuma.work/2025/11/20251111-rst.html)
