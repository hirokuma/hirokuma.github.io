---
layout: record
title: "HTLC"
tags:
  - bitcoin
daily: false
create: "2025/08/01"
date: "2026/05/10"
draft: true
---

## Hash Time-Locked Contracts

[BIP-112](https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki#hash-time-locked-contracts)の表記にあわせた。  
"hashed"だったり、ハイフンがなかったり、"lock" だったりと人によって表現が違うが、とにかく略称は HTLC である。

BitcoinやEthereumにはスクリプトやスマートコントラクトと呼ぶ機能があり、送金に条件を付けることができる。  
HTLCは、ハッシュ値の元データを知っていると解けるようにする。知らない場合でも一定期間を過ぎると勝手に解けるようにしたスクリプトである。
それだけだと偶然元データを知っていたり・・・ということはなくても、期間が過ぎたら誰でも解けてしまうので、特定の鍵で署名できないようにしておくのが一般的だ。

### P2WSH

P2WSHまでの書き方だとこういうスクリプトになる。  
`OP_IF` のルートで解くためにはSHA256計算して `<hash>` となる値(preimage)と `<pubkey A>` に対応する秘密鍵でのトランザクション署名がいる。  
`OP_ELSE` のルートで解くためには `<delay>` 以上のconfirmationと `<pubkey B>` に対応する秘密鍵でのトランザクション署名がいる。

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

このスクリプトへ送金するトランザクションはBが展開し、Bがpreimageを作ってAにhashを渡す、という使い方になる。
`OP_ELSE` の `<delay>` が経過する前にAはBとの約束を果たすことで、AはBからpreimageをもらい、スクリプトを解くトランザクションを作って展開することで報酬をもらう。
もしAが約束を果たさなければ、期間さえ過ぎればBはトランザクションを展開して取り戻す。  
preimageを知っているBは `OP_IF` のルートを通ることはできるが `<pubkey A>` の秘密鍵を知らないので正しい署名を渡すことができない。
また、Aがpreimageをもらえたとしても展開するのが `<delay>` 以降になってしまうようだと先にBがトランザクションを展開することができてしまう。
そういったことも考慮して余裕を持った値にしておくべきである。

### P2TR

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

どちらかが始めないといけないので、上のスクリプトに合わせてBobからにする。

### 1. Bob

Bobはランダムな32byte値を作る。
これを "preimage" と呼ぶ。

そして、そのランダム値をSHA256した値を計算しておく。
これを "payment hash" と呼ぶ。

呼び名はLightning Networkで使われている名称を使った。

### 2. Bob -> Alice

BobはAliceに`1`で作ったpayment hashと、BobのBitcoinアドレスの元になった公開鍵を渡す。
preimageは渡したり公開したりしないこと。

### 3. Alice

BobはAliceにBobのEthereumアドレスを渡す。

### 4. Alice

Alice

「このSHA256の値の元データであるpreimageを知っている人はAliceに送金でき、それ以外で2日経過したらBobに送金するスクリプト」を展開する。  


今はAliceだけがpreimageを知っている。  
preimageを知っていれば解くことができるコントラクトなので、

#### 3b. Bob

BobはBitcoin上で「このSHA256の値の元データを知っている人はAliceに送金でき、それ以外で1日経過したらBobに送金するBitcoinスクリプト」をBitcoin上に展開する。  
Aliceが展開してconfirmしたのを確認し、そのスマートコントラクトが受け入れる期間よりも確実に短くなるようにする。





