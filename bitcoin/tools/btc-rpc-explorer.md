---
layout: record
title: "janoside/btc-rpc-explorer"
tags:
  - bitcoin
daily: false
create: "2025/08/03"
date: "2026/05/19"
---

## サイト

* [repository: github.com/janoside/btc-rpc-explorer](https://github.com/janoside/btc-rpc-explorer)

直接 `bitcoind` を参照するので、regtestで構築するだけならこちらが楽か。  
Electrum APIの設定もあるので、そちらでも使えるかも(試していない)？

## インストール

```console
$ git clone https://github.com/janoside/btc-rpc-explorer.git
$ cd btc-rpc-explorer
$ npm install
```

グローバルインストールしない場合は `.env`ファイルを使うのが無難そう。

```toml
BTCEXP_PORT=8080
BTCEXP_BITCOIND_URI=bitcoin://testuser:testpass@127.0.0.1:18443?timeout=10000
```

起動。

```console
$ npm start
```

## Address API

アドレスで検索できるようにするには何らかのAddress API設定が必要である。
ローカル環境の場合は[electrs](./electrs.md)を立てるのが簡単か。

```toml
BTCEXP_ELECTRUM_SERVERS=tcp://127.0.0.1:50001
BTCEXP_ADDRESS_API=electrum
```
