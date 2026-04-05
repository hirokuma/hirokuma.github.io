---
layout: record
title: "rust: BDK"
tags:
  - bitcoin
  - library
  - rust
daily: false
create: "2025/10/15"
date: "2026/03/22"
---

[site](https://bitcoindevkit.org/)

* repository
  * [bdk](https://github.com/bitcoindevkit/bdk)
  * [bdk_wallet](https://github.com/bitcoindevkit/bdk_wallet)

_調査日:2026/03/22_:

* bdk_wallet: 2.3.0
* bdk_*: 0.23.2

これを書いている時点(2026/03/22)では「v1.0系」となっている。
`bdk_wallet` クレートが v2.3.0、それ以外のクレートが v0.23.2 である。  
`bdk` というクレートは「v0系」で、v1.0系にはない。

## 使い方

* [confirmation数の取得](./bdk/confirmation.md)

## リンク

* 開発日記
  * [rust: rust-bitcoin と BDK (5) - hiro99ma blog](https://blog.hirokuma.work/2025/09/20250923-rst.html)
  * [rust: rust-bitcoin と BDK (6) - hiro99ma blog](https://blog.hirokuma.work/2025/10/20251002-rst.html)
  * [rust: rust-bitcoin と BDK (8) - hiro99ma blog](https://blog.hirokuma.work/2025/10/20251005-rst.html)
  * [bdk: SyncRequest - hiro99ma blog](https://blog.hirokuma.work/2026/03/20260314-bdk.html)

* サンプルコード
  * [hirokuma/bdk-example](https://github.com/hirokuma/bdk-example)
