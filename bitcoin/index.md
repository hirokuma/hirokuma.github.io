---
layout: "record"
title: "Bitcoin調査"
tags:
  - bitcoin
daily: false
date: "2026/01/30"
---

## 注意！

このサイトでは Bitcoin の購入を含め、仮想通貨の購入を勧める行為はしません。  
売買するのは個人の自由だが、このサイトはそういう目的のために調査しているわけではない。

## 基本

* [インストール](01_basics/install.md)
  * [ビルド](01_basics/build.md)
* [Bitcoin Core(bitcoind) を regtest で動かす](01_basics/bitcoind.md)
  * [標準ポート番号](01_basics/port.md)
* [値の表現](01_basics/value.md)
* [ブロック](01_basics/blocks.md)
* [トランザクション](01_basics/transactions.md)
  * [スクリプト](01_basics/script.md)
  * [Miniscript](01_basics/miniscript.md)
  * [PSBT v0](01_basics/psbt_v0.md)
  * [MuSig2シーケンス](musig/musig2_sequence.md)
* [アドレス](01_basics/address.md)
  * [P2WPKH](02_addr/p2wpkh.md)
  * [P2WSH](02_addr/p2wsh.md)
  * [P2TR](02_addr/p2tr.md)
* [ウォレット](01_basics/wallet.md)
* [txout proof](01_basics/txoutproof.md)

## 小技

* [初期ブロックダウンロードが終わったかどうか](03_tips/initialdownloaded.md)
* [Public KeyからscriptPubKeyを得る](03_tips/pubkey2scriptpubkey.md)
* [Regtest環境でfee rateを得たい](03_tips/regtest-feerate.md)
* [Bitcoin CoreでOP_RETURNありTXを作りたい](03_tips/bitcoincore-opreturn.md)

## ライブラリ

* [C/C++](library/clang.md)
  * [libwally-core](library/libwally.md)
* [JavaScript/TypeScript](library/js.md)
* [Go](library/go.md)
* [Rust](library/rust.md)
  * [BDK](library/bdk.md)

## ツール

* デバッグ
  * [btcdeb](tools/btcdeb.md)
* Electrum Server
  * [Electrum Protocol — electrum-protocol Electrum Protocol 1.6.x documentation](https://electrum-protocol.readthedocs.io/en/latest/)
  * [romanz/electrs](tools/electrs.md)
  * [Blockstream/electrs](tools/electrs-bs.md)
  * [mempool/electrs](tools/electrs-ms.md)
* Block Explorer
  * [Blockstream/esplora](tools/esplora.md)
  * [janoside/btc-rpc-explorer](tools/btc-rpc-explorer.md)

### 自作

* [hirokuma/bitcoin-flow-dot](https://github.com/hirokuma/bitcoin-flow-dot/tree/f7665b37d6811d780e439a67ad7b2735a36d560e)
  * [開発日記:トランザクションのつながり図](/2025/06/20250615-btc.html)
* [gist: hirokuma/start-new-bitcoind-with-feerate.sh](https://gist.github.com/4feb14eea9ccccd0e2d42e8c90d434c6.git)
  * [Regtest環境でfee rateを得たい](03_tips/regtest-feerate.md)
* [gist: hirokuma/regtest環境スクリプト類](https://gist.github.com/hirokuma/6a8d1553a813fa569599d5b0f54f722a)

## リンク集

### Source codes

* [GitHub: bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
* [GitHub: bitcoin/bips](https://github.com/bitcoin/bips)

### 解説

* [Developer Guides — Bitcoin](https://developer.bitcoin.org/devguide/)
  * [Reference — Bitcoin](https://developer.bitcoin.org/reference/)

* [Learn Me A Bitcoin (By Greg Walker)](https://learnmeabitcoin.com/)

### 情報

* [マスタリング・ビットコイン 第3版 - O'Reilly Japan](https://www.oreilly.co.jp/books/9784814401444/)
* [Weekly Recap on the Bitcoin ecosystem - th_sat - Substack](https://thsatcrypto.substack.com/)
