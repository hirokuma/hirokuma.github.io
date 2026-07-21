---
layout: record
title: "HTLC"
tags:
  - bitcoin
daily: false
create: "2025/08/01"
date: "2026/07/20"
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
P2TRのscript path spendでは`OP_CHECKSIG`系でのpubkeyはtweakedではなくinternalの方である。
key path spendではtweakedをwitnessに使うので間違えないよう。  
簡単に言えば、secp256k1のprivate keyとそれから導出したpublic key(X only)を使えばよいだけである。

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
事前に、お互いのEthereumアカウント(ETH-Alice, ETH-Bob)と、HTLCのタイムアウト時間(HTLC-CSV, HTLC-Timestamp)は決めておいたものとする。  
また、EthereumのHTLCスマートコントラクトは展開済みとする。

### 1. Bob

Bobはランダムな32byte値を作る。
これを "preimage" と呼ぶ。

そして、そのランダム値をSHA256した値を計算しておく。
これを "preimage_hash" と呼ぶ(Lightning Networkだと"payment_hash"と呼んでいたので決まった名称はないのかも)。

### 2. Bob -> Alice

BobはAliceに以下を渡す。

* `1`で作ったpreimage_hash
* タイムアウトしたときのルートで署名検証する公開鍵(PUBKEY-Bob)

Bobはpreimageを知っているが、そのルートのスクリプトを解いても次に必要なのはAliceの公開鍵検証に成功しなくてはならないので、実質的にBobにはそのルートを通すことができない。  
できるのは、スクリプトがタイムアウトしてBobが支払った分を取り戻す経路を通すことだけである。

### 3. Alice

AliceはBobに、preimageでスクリプトを解いた後に署名検証する公開鍵(PUBKEY-Alice)を渡す。  
`2`でBobからもらったデータと、Aliceの公開鍵を組み合わせることでBitcoinのHTLCスクリプトを作ることができる。

```text
OP_SHA256 <preimage_hash> OP_EQUALVERIFY <PUBKEY-Alice> OP_CHECKSIG
```

```text
<HTLC-CSV> OP_CHECKSEQUENCEVERIFY OP_DROP <PUBKEY-Bob> OP_CHECKSIG
```

AliceもBobも同じスクリプトを作るデータを持っているので、HTLCアドレスも同じものになる。

preimageを知っているBobが有利なので、先にBobがHTLCアドレスにBTCを送金しておく。

### 4. Alice

AliceはBobがHTLCアドレスに送金したことを確認すると、Ethereum側のスマートコントラクトの呼び出しを行う。  
EtehreumのHTLCの方が関数になっていてわかりやすいかもしれない。AIで生成できるくらいには普通のやり方である。

* lock : preimage_hash、送金元、送金先、金額などをハッシュにしたキーにして、そこにAliceのETHを送金して資金をロックする
* claim: 資金をロックしたときと同じパラメータで、preimage_hashの代わりにpreimageを与えることができればロックした資金を送金先に自動で送る

ここでAliceが呼び出すのはlockの方である。  
lock成功時にEventを発行するようにしておき、Bobはブロックチェーンから直接lockが実行されたことを知ることができる。

### 5. Bob

preimageを知っているBobはclaim関数を呼び出すことができる。
もしパラメータをすべて知っていれば、Bobでなくても誰でもこのclaim関数呼び出しを成功させることはできる。
しかし、その送金先はあらかじめ決められているので特に利点はない。
Gas代がかかるのでむしろマイナスである。

claim成功時にも同様にEventを発行するようにしておく。
これでようやくAliceもpreimageを手に入れることができた。

### 6. Alice

preimageがあり、AliceがHTLCに組み込んだ秘密鍵があればBitcoinのHTLCスクリプトを解くことができる。  
Ethereum側と違って署名検証が必要なのは、Bitcoinの場合はスクリプトを解いてしまえばその送金先は自由に設定できるからだ。
現在のBitcoinではそういうことはできないので、署名検証を挟むことで本人確認のようなことをしているわけである。

## HTLCの鍵はウォレットと別にするのが良い

HTLCのスクリプトでは、だいたい署名の検証まで行うようにする。
そうしないと条件が一致してしまったら誰でもspendできてしまうからだ。

その検証に関する鍵だが、別にウォレットと関係している必要はない。
preimageがこの場限りの値であるのと同様に一時的な鍵セットでよい。  
P2TRではinternal pubkeyを使うので、そちらの方が実装的にも楽だ。
