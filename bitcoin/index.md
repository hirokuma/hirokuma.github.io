---
layout: "record"
title: "Bitcoin調査"
tags:
  - bitcoin
daily: false
date: "2025/06/19"
---

Bitcoin技術に関する調査メモを残すページ。

## 禁止事項

* このサイトでは Bitcoin の購入を含め、仮想通貨の購入を勧める行為はしません
  * 売買するのは個人の自由だが、このサイトはそういう目的のために調査しているわけではない

## はじめに

Bitcoin技術は更新が続いているので、ここに書いたことも「当時は正しかったかもしれないが」ということになるかもしれない。  
読む人も注意して、記事を信用しないように。  
よく言われる「Don't trust, verify」である。

最終的には「プログラムで書かれているのでそれを解読するのが正しい」になってしまうが、そんなことをしていたら時間がいくらあっても足りなくなる。
なので、その人が言っているのと別の情報源から確認することが多くなるだろう。

実際にコーディングする場合は信用できるライブラリだけを使うようにしよう。  
まったくライブラリを使わずにコーディングするのはもはや無理な世界だと思う。

## 基本

* [インストール](01_basics/install.md)
* [Bitcoin Core(bitcoind) を regtest で動かす](01_basics/bitcoind.md)
  * [標準ポート番号](01_basics/port.md)
* [値の表現](01_basics/value.md)
* [ブロック](01_basics/blocks.md)
* [トランザクション](01_basics/transactions.md)
* [アドレス](01_basics/address.md)
  * [P2WPKH](02_bip/p2wpkh.md)
  * [P2WSH](02_bip/p2wsh.md)
  * [P2TR](02_bip/p2tr.md)
* [ウォレット](01_basics/wallet.md)
* [txout proof](01_basics/txoutproof.md)

## 小技

* [初期ブロックダウンロードが終わったかどうか](03_tips/initialdownloaded.md)

## ライブラリ

* [C/C++](library/clang.md)
* [JavaScript/TypeScript](library/js.md)
* [Go](library/go.md)

## ツール

* [btcdeb](tools/btcdeb.md)
* [romanz/electrs](tools/electrs.md)
* [Blockstream/electrs](tools/electrs-bs.md)
* [Blockstream/esplora](tools/esplora.md)

### 自作

* [hirokuma/bitcoin-flow-dot](https://github.com/hirokuma/bitcoin-flow-dot/tree/f7665b37d6811d780e439a67ad7b2735a36d560e)
  * [開発日記:トランザクションのつながり図](/2025/06/20250615-btc.html)

## リンク集

### Source codes

* [GitHub: bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
* [GitHub: bitcoin/bips](https://github.com/bitcoin/bips)

### 解説

* [Developer Guides — Bitcoin](https://developer.bitcoin.org/devguide/)
  * [Reference — Bitcoin](https://developer.bitcoin.org/reference/)

* [Learn Me A Bitcoin (By Greg Walker)](https://learnmeabitcoin.com/)
