---
layout: record
title: ""
tags:
  - 
daily: false
date: "2025/08/03"
---

[repository](https://github.com/janoside/btc-rpc-explorer)

直接 `bitcoind` を参照するので、regtestで構築するだけならこちらが楽か。  
Electrum APIの設定もあるので、そちらでも使えるかも(試していない)？

## インストール

```console
$ git clone https://github.com/janoside/btc-rpc-explorer.git
$ cd btc-rpc-explorer
$ npm install
```

グローバルインストールしない場合は `.env`ファイルを使うのが無難そう。

```bash
BTCEXP_PORT=8080
BTCEXP_BITCOIND_URI=bitcoin://testuser:testpass@127.0.0.1:18443?timeout=10000
```

起動。

```console
$ npm start
```
