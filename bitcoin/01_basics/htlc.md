---
layout: record
title: "HTLC"
tags:
  - bitcoin
daily: false
date: "2025/08/01"
draft: true
---

## Hash Time-Locked Contracts

[BIP-112](https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki#hash-time-locked-contracts)の表記にあわせた。  
"hashed"だったり、ハイフンがなかったり、"lock" だったりと人によって表現が違うが、とにかく略称は HTLC である。

BitcoinやEthereumにはスクリプトやスマートコントラクトと呼ぶ機能があり、送金に条件を付けることができる。  
HTLCは、ハッシュ値の元データを知っていると解けるようにする。知らない場合でも一定期間を過ぎると勝手に解けるようにしたスクリプトである。
それだけだと偶然元データを知っていたり・・・ということはなくても、期間が過ぎたら誰でも解けてしまうので、特定の鍵で署名できないようにしておくのが一般的だ。

P2WSHまでの書き方だとこういうスクリプトになる。

```text
OP_SHA256 <hash> OP_EQUAL
OP_IF
    <pubkey A>
OP_ELSE
    <delay> OP_CHECKSEQUENCEVERIFY OP_DROP
    <pubkey B>
OP_ENDIF
OP_CHECKSIG
```

P2TRならscript pathを分けた方が小さくなる。

```text
OP_SHA256 <hash> OP_EQUALVERIFY <pubkey A> OP_CHECKSIG
```

```text
<delay> OP_CHECKSEQUENCEVERIFY OP_DROP <pubkey B> OP_CHECKSIG
```

C言語で P2TR の HTLC を実装したサンプルを置いておく。

* [C language HTLC sample](https://github.com/hirokuma/c-scriptpath/tree/main/htlc)

## 主な用途

用途はいろいろあると思うので、よくあるアトミックスワップ(atomic swap)の説明をする。  
BitcoinとEthereumを交換する例にしたが、Ethereumのコントラクトは載せていないので自分で考えてください。  
Ethereumでなくても以下のような条件があれば使えるはずだ。

* 期間を決めるスクリプトを書くことができる
* 同じハッシュ演算ができる
* スクリプトを解いて送金されるときにオンチェーンに展開されて説いた内容を誰でも見ることができる

Ethereumを持つAliceとBitcoinを持つBobがいたとする。
AliceがBobにEthereumを支払い、BobがAliceにBitcoinを支払う、という交換をしたい。

どちらかが始めないといけないので、ここではAliceからスタートしたとする。  

### 1. Alice

Aliceはランダムな32byte値を作る。
これを "preimage" と呼ぶ。

そして、そのランダム値をSHA256した値を計算しておく。
これを "payment hash" と呼ぶ。

呼び名はLightning Networkで使われている名称を使った。

### 2. 

AliceはBobに`1`で作ったpayment hashとAliceのBitcoinアドレスを渡す。  
BobはAliceにBobのEthereumアドレスを渡す。

### 3 Alice and Bob

#### 3a. Alice

AliceはBobに

「このSHA256の値の元データであるpreimageを知っている人はAliceに送金でき、それ以外で2日経過したらBobに送金するスクリプト」を展開する。  


今はAliceだけがpreimageを知っている。  
preimageを知っていれば解くことができるコントラクトなので、

#### 3b. Bob

BobはBitcoin上で「このSHA256の値の元データを知っている人はAliceに送金でき、それ以外で1日経過したらBobに送金するBitcoinスクリプト」をBitcoin上に展開する。  
Aliceが展開してconfirmしたのを確認し、そのスマートコントラクトが受け入れる期間よりも確実に短くなるようにする。





