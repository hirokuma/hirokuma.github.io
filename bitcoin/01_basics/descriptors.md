---
layout: record
title: "Output Descriptors"
tags:
  - bitcoin
daily: false
date: "2025/09/25"
draft: true
---

## 目的

BIP-32 の HDウォレットや BIP-39 のニモニックだけでは解決できないウォレットに関する問題点を解決する。

* [BIP-380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki)
  * [BIP-381](https://github.com/bitcoin/bips/blob/master/bip-0381.mediawiki)
  * [BIP-382](https://github.com/bitcoin/bips/blob/master/bip-0382.mediawiki)
  * [BIP-383](https://github.com/bitcoin/bips/blob/master/bip-0383.mediawiki)
  * [BIP-384](https://github.com/bitcoin/bips/blob/master/bip-0384.mediawiki)
  * [BIP-385](https://github.com/bitcoin/bips/blob/master/bip-0385.mediawiki)
  * [BIP-386](https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki)
  * [BIP-390](https://github.com/bitcoin/bips/blob/master/bip-0390.mediawiki)

## Output Descriptors を考案するに至った問題点

* BIP-32 の HDウォレットは鍵を導出するためのしくみである
* BIP-39 はウォレットの秘密鍵を記録しやすくするが、HDウォレットの `m` の部分しか復元できない
* すべてのウォレットが BIP-32 のあらゆる導出パスをサポートしているとは限らない。BIP-84 のみ、みたいに自アプリがサポートする導出パスのみサポートしていることも多い。
* エクスポートするときも BIP-39 のニモニックだけしかなく、どのウォレットなら復元して使用できるのかなどの情報がない

## 文法

`<SCRIPT>(#<CHECKSUM>)`

### `<SCRIPT>`: Script Expressions

* `<SCRIPT>`
* `<KEY>`
* その他

### `<KEY>`: Key Expressions

* (optional) key origin information
  * `[` + `<fingerprint>` + `PATH` + `]`
    * `<fingerprint>`: 8文字のHEX。BIP-32参照。
    * `<PATH>`: 0個以上の `/NUM` か `/NUMh`(hardened)
* HEX形式の鍵...
  * 公開鍵
    * `02` か `03` で始まる 66文字のHEX(圧縮公開鍵)。
    * `04` で始まる 130文字のHEX(非圧縮公開鍵)。
  * 秘密鍵
    * WIF形式
  * 拡張公開鍵 / 拡張秘密鍵
    * `xpub` か `xprv` で始まり、0個以上の `/NUM` か `/NUMh`(hardened)が続く
      * testnet では `tpub` や `tprv` などになる
    * optional で `/*` や `/*h` 
      * BIP-44 などの `m / purpose' / coin_type' / account' / change / address_index` でいう `address_index` は `*` になりやすいだろう

hardened は `h` でも `'` (シングルクォーテーション) でもよい。

### `#<CHECKSUM>`: Checksum

* 省略可能
  * 省略されているとウォレットが読み込まないかもしれない
* 8文字の英数字
  * 使用する文字は [bech32](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32) と同じく `qpzry9x8` `gf2tvdw0` `s3jn54kh` `ce6mua7l`
* error correcting checksum になっているので多少であれば自動で修正できるのだと思うが、限度があるので期待しすぎないようにしよう
* Python3 での checksum 算出とチェックコード
  * [gist - descriptors_checksum.py](https://gist.github.com/hirokuma/bbae79effd16d8345e7fa4f5fa1d70ee)
