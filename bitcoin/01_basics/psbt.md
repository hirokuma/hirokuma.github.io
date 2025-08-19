---
layout: record
title: "PSBT"
tags:
  - bitcoin
daily: false
date: "2025/08/19"
draft: true
---

## はじめに

"Partially Signed Bitcoin Transaction"の略。

ときどき、署名だけを他の人にやってもらいたいという状況がある。
MultiSig のようなこともあれば、鍵を持たせないアプリでトランザクションだけ作って署名はウォレットで行う、ということもあるだろう。

PSBT はそういったときに使用できるデータフォーマットである。  
これがないときは各アプリでフォーマットを決めていたので共通性がなかった。

現在(2025/08/19)のところ version 0(BIP-174) と version 2(BIP-370) の 2つがある。version 1 はない。

詳細は各人で確認するのが良い。自分でデータを作るよりもツールやAPIなどでやった方がよいだろう。  
たとえば C言語系なら [libwally-core/psbt](https://wally.readthedocs.io/en/latest/psbt.html) が使えるだろう(Pythonのラッパーもあると思う)。
スクロールバーを見ると分かるが、非常に項目が多い。  
[bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib)はトランザクションを作るときはだいたい PSBT 関連の構造体を使っていたように思う。

などなど、API で見てしまうと切りがない。  
ここでは私が気になったところだけにする。

## version 0 と 2 の違い

[BIP-370](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki#abstract)に

> which allows for inputs and outputs to be added to the PSBT after creation.

と書かれているので、BIP-174 に後からでも INPUT/OUTPUT を追加できるようにしたと思われる。



## 関連ページ

* [BIP174 - PSBT version 0](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki)
* [BIP370 - PSBT version 2](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki)
* [Partially signed bitcoin transactions - Bitcoin Optech](https://bitcoinops.org/en/topics/psbt/)
* [PSBT - Partially Signed Bitcoin Transaction](https://learnmeabitcoin.com/technical/transaction/psbt/)
