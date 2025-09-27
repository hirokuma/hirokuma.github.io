---
layout: "record"
title: "ウォレット"
tags:
  - bitcoin
daily: false
date: "2025/09/26"
---

## HDウォレット

自分の Bitcoinアドレスは自分だけが知っている秘密鍵から作る。  
秘密鍵は他の人が推測できないようにランダム値を使う。  
Bitcoinではアドレスを使い回すのをよしとしないので、受信アドレスを作ったり、送信でお釣りを受け取るアドレスを作ったり、とにかくアドレスがたくさん必要になる。

素直に毎回ランダム値で秘密鍵を作っていくと、鍵のバックアップを毎回残さないといけないが、これは運用が面倒である。  
そこで、鍵を機械的に作りつつ、しかしそれぞれの秘密鍵の関係はわからないとされる方式が考え出された。  
それが HDウォレット(Hierarchical Deterministic Wallet)である。
日本語では「階層的決定性ウォレット」などとも呼ばれる。

* [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
  * [BIP-44 - P2PKH](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
  * [BIP-49 - P2WPKH nested in P2SH](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki)
  * [BIP-84 - P2WPKH](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki)
  * [BIP-86 - P2TR](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki)

(ここに階層の図を入れる)


### Master Seed と Master Key

* [Master key generation](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#master-key-generation)

まず Master Seed を求める。  
Master Seed は 128～512 bits の乱数を求める(推奨は 256 bit)。
できるだけちゃんとした乱数を使用すること。

Master Seed はそのまま使うのでは無く、
Key="Bitcoin seed"、Data=seed で HMAC-SHA512 計算をした値を `I` とし、それを長さで半分に分割し <code class="language-plaintext highlighter-rouge">I<sub>L</sub></code>、<code class="language-plaintext highlighter-rouge">I<sub>R</sub></code> とする(左半分と右半分)。  
左半分が master secret key、右半分が master chain code でそれぞれ長さは 256 bit である。  
<code class="language-plaintext highlighter-rouge">I<sub>L</sub></code> が 0 と等しいか `n` 以上だと NG。  
両方ひっくるめて Master Key `m` と呼び、これから階層を下りながら生成していく extended key の親玉である。

### Extended Key

* [extended key](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#extended-keys) はこう。

* extended private key(拡張秘密鍵) は前半 256 bit が private key で後半 256 bit が chain code
* extended public key(拡張公開鍵) は前半 256 bit がその public key で後半 256 bit が chain code

Master Key から階層を下りながら鍵を作っていく。

* 拡張秘密鍵からは拡張公開鍵を作ることができ、子拡張秘密鍵も子拡張公開鍵も作ることができる。
* 拡張公開鍵からは子拡張公開鍵を作ることができる。
* 子から親を作ることはできない。

一度に数段下の階層の拡張鍵を作ることはできないので、`change` の階層で公開用とお釣り用の拡張鍵を作っておき、各アドレスはそれぞれ拡張鍵から派生させるのが効率よいと思われる。

### 鍵導出

HDウォレットは階層構造になっていて、最上位の `m` から下に降りていく。  
`/` はファイル構造のパス区切りと同じものと考えて良い。  
各階層は実際には符号無し32bit整数で表される。
`'` は "hardened" を意味し、最上位ビットを立てる。

Bitcoin の運用としては次の説明にあるように 5階層としているが、計算上はどの階層でも鍵導出できる。
自作するときにこの階層を間違うと他のウォレットで鍵の復元ができなくなるので注意しよう。

### 階層構造の運用

Bitcoin で BIP-32 の HDウォレットを使う場合は以下の階層構造を用いる(BIP44, 49, 84, 86など)。

```
m / purpose' / coin_type' / account' / change / address_index
```

`m` がルートで、深さを 0 と考えると `address_index` は深さが 5 になる。  

「ウォレットを作る」としたときに 12単語や 24単語のニモニック(場合によってはパスフレーズも)を記録するが、
それだけだとこの階層では最初の `m` だけしか決まらない。  
HDウォレットには階層があり、それぞれの階層の値も同じにしないと同じアドレスは復元できない。

* `purpose'`: 該当する BIP の番号(P2PKH=44, P2WPKH nested in P2SH=49, P2WPKH=84, P2TR=86)
* `coin_type'`: "Bitcoin mainnet" や "Bitcoin testnet"(regtest などもたぶん含む)
* `account'`: 切り替えて使いたい場合
* `change`: `0` が受信アドレス(公開用)、`1` がお釣りアドレス(内部用)
* `address_index`: アドレスを作るごとに増やしていく値

### 主な使い方

鍵を作る場合、同じ種類(P2WPKH や P2TR)のアドレスを作ることになる。  
なので `m / purpose' / coin_type' / account'` まで鍵導出し、
あとは公開用なのかお釣り用なのかで `change` を選択肢、最後に `address_index` を決める。  
`change` ごとの `address_index` を管理して、最後に作った `address_index` をインクリメントしていくことになるだろう。

ウォレットに紐付く UTXO を探す場合、`address_index` をインクリメントさせながら調べていく。
32 bit あるので全部の空間を調べることはできない。
アドレスを作ったけど受信しなかったということもあるので、
デフォルトでは UTXO が見つからないアドレスが 20個続いた場合は探索を打ち切る([gap limit](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#address-gap-limit))。  
あくまでデフォルトなので、設定が変更可能なウォレットもある。

### シリアライズ

| name | length | note |
| ---- | ---- | ---- |
| [version bytes](#prefix-と-version-bytes) | 4 |  |
| depth | 1 | |
| [fingerprint](#fingerprint) | 4 | |
| child number | 4 | |
| [chain code](#Master-Seed-と-Master-Key) | 32 | |
| privkey or pubkey | 33 | privkey は先頭に `00` を付ける |

#### prefix と version bytes

| type | mainnet private | mainnet public | testnet private | testnet public |
| ---- | ---- | ---- | ---- | ---- |
| [P2PKH](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#serialization-format) | `xprv`(`0x0488ade4`) | `xpub`(`0x0488b21e`) | `tprv`(`0x04358394`) | `tpub`(`0x043587cf`) |
| [P2WPKH-nested-in-P2SH](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#extended-key-version) | `yprv`(`0x049d7878`) | `ypub`(`0x049d7cb2`) | `uprv`(`0x044a4e28`) | `upub`(`0x044a5262`) |
| [P2WPKH](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#extended-key-version) | `zprv`(`0x04b2430c`) | `zpub`(`0x04b24746`) | `vprv`(`0x045f18bc`) | `vpub`(`0x045f1cf6`) |
| [P2TR(single key)](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki#test-vectors) | `xprv`(`0x0488ade4`) | `xpub`(`0x0488b21e`) | `tprv`(`0x04358394`) | `tpub`(`0x043587cf`) |

### fingerprint

* [Key identifiers](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers)

階層として 1つ上の extended public key を HASH160 した先頭 4バイトを fingerprint と呼ぶ。  
ただし master key の場合は `00000000` を使用する。

## 関連ページ

* [bitcoind](./bitcoind.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
* [Output Descriptors](./descriptors.md)
