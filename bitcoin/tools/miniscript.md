---
layout: record
title: "Miniscript"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/08/05"
draft: true
---

## サイト

* [Miniscript](https://bitcoin.sipa.be/miniscript/)
* [repository: github.com/sipa/miniscript](https://github.com/sipa/miniscript)

## 概要

MiniscriptはBitcoinスクリプトを構造的に書くための言語である。

Bitcoinスクリプトは、高級言語というよりも逆ポーランド記法の方が近いと思う。
値をスタックに載せ、スタックに対して命令を実行し、最終的にスタックが1つになって `0` 以外なら true、`0` なら false と判定される。
[Script](https://en.bitcoin.it/wiki/Script)に表があるが、この "Output"列で "fail" がある命令は、その場でスクリプトの判定を失敗扱いにして終わる。

例えば[こういう](https://github.com/lightning/bolts/blob/master/03-transactions.md#to_local-output)ものである。

```text
OP_IF
    <revocationpubkey>
OP_ELSE
    `to_self_delay`
    OP_CHECKSEQUENCEVERIFY
    OP_DROP
    <local_delayedpubkey>
OP_ENDIF
OP_CHECKSIG
```

TapScriptでは分岐させずにスクリプト自体を別々に作ることが多いだろうが、ともかくこういう書き方になる。
`<revocationpubkey>` は 33バイトの公開鍵で `to_self_delay` はスタックに載せる命令になる。

(書きかけ)

## リンク

* 開発日記
  * [btc: miniscript - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250307-btc.html)
  * [btc: miniscript (2) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250308-btc.html)
  * [btc: miniscript (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250311-btc.html)
  * [btc: Output Descriptors - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250224-btc.html)
  * [btc: Output Descriptors (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250225-btc2.html)
  * [btc: Output Descriptors (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250301-btc.html)
  * [btc: Output Descriptors (4) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250302-btc.html)
  * [btc: Output Descriptors (5) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250303-btc.html)
