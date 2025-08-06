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

## ビルド

```console
$ git clone https://github.com/sipa/miniscript.git
$ cd miniscript
$ make

$ echo "pk(key_1)" | ./miniscript
X    108.0000000000    35 pk(key_1) pk(key_1)
```

オリジナルをビルドしたコマンドではBitcoinスクリプトまでは出力しないので、forkして[サイト](https://bitcoin.sipa.be/miniscript/)で出力している項目を追加した。

```console
$ git clone https://github.com/hirokuma/miniscript.git
$ cd miniscript
$ make

$ echo "pk(key_1)" | ./miniscript
<<Spending cost>>
script_size=   35
input_size=    73.0000000000
total_cost=   108.0000000000

<<miniscript output>>
pk(key_1)

<<Resulting script structure>>
<key_1> OP_CHECKSIG
```

JavaScriptとWASMのコードも生成できる。

```console
$ sudo apt install emscripten
$ make miniscript.js
```

これらのファイルが生成された後であれば、ローカルのブラウザで `index.html` を開くと[サイト](https://bitcoin.sipa.be/miniscript/)と同じことができた。

## 概要

MiniscriptはBitcoinスクリプトを構造的に書くための言語である。

このリポジトリはサンプルコードを含んでいるライブラリだと考えるのがよいと思う。
`index.html` はサンプルであると同時に help 代わりにもなっていて、
[BIP-379](https://github.com/bitcoin/bips/blob/master/bip-0379.md)の説明をしている。

プログラムで動的にスクリプトを生成するために組み込むという使い方になると思っている。

## 使い方

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

* [bips/bip-0379.md at master · bitcoin/bips](https://github.com/bitcoin/bips/blob/master/bip-0379.md)
* [Miniscript - Bitcoin Optech](https://bitcoinops.org/en/topics/miniscript/)
* [rust-bitcoin/rust-miniscript: Support for Miniscript and Output Descriptors for rust-bitcoin](https://github.com/rust-bitcoin/rust-miniscript)
* 開発日記
  * [btc: miniscript - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250307-btc.html)
  * [btc: miniscript (2) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250308-btc.html)
  * [btc: miniscript (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250311-btc.html)
  * [btc: Output Descriptors - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250224-btc.html)
  * [btc: Output Descriptors (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250225-btc2.html)
  * [btc: Output Descriptors (3) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250301-btc.html)
  * [btc: Output Descriptors (4) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250302-btc.html)
  * [btc: Output Descriptors (5) - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250303-btc.html)
