---
layout: "record"
title: "ウォレット"
tags:
  - bitcoin
daily: false
date: "2025/09/25"
---

## HDウォレット

* [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
* [BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
* [BIP-84 - P2WPKH](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki)
* [BIP-86 - P2TR](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki)

(ここに階層の図を入れる)

[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki) は鍵導出について、[BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) は各階層(path)の用途を決めている。  

```
m / purpose' / coin_type' / account' / change / address_index
```

「ウォレットを作る」としたときに 12単語や 24単語のニモニック(場合によってはパスフレーズも)を記録するが、
それだけだとこの階層では最初の `m` だけしか決まらない。  
`purpose'` が P2TR(86') や P2WPKH(84') などを決めているので、これも記録しておかないと面倒だ(数種類なので全部試せば良いのだが、それが面倒だと思う)。  
`coin_type'` は "Bitcoin mainnet" や "Bitcoin testnet"(regtest などもたぶん含む)、おそらく Ethereum なども使っているんじゃ無かったか。  
`account'` はおそらく切り替えて使いたい場合、`change` は `0` が受信アドレス(公開用)、`1` がお釣りアドレス(内部用)。
`address_index` はアドレスを作るごとに増やしていく値。

ウォレットに紐付く UTXO を探す場合、`address_index` をインクリメントさせながら調べていく。
32 bit あるので全部の空間を調べることはできない。
アドレスを作ったけど受信しなかったということもあるので、
デフォルトでは UTXO が見つからないアドレスが 20個続いた場合は探索を打ち切る([gap limit](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki#address-gap-limit))。  
あくまでデフォルトなので、20個調べたら必ず打ち切る、というものではない。

### seed

seed は 128～512 bits の乱数である。  
BIP-32 では 256 bit を推奨していたが今もそうなのかは未確認。

### master key と chain code

* [Master key generation](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#master-key-generation)

Key="Bitcoin seed"、Data=seed で HMAC-SHA512 計算をした値を `I` とし、それを半分に割って <code class="language-plaintext highlighter-rouge">I<sub>L</sub></code>、<code class="language-plaintext highlighter-rouge">I<sub>R</sub></code> とする(左半分と右半分)。  
左半分が master secret key、右半分が master chain code である。  
<code class="language-plaintext highlighter-rouge">I<sub>L</sub></code> が 0 と等しいか `n` 以上だと NG。

### 拡張鍵

* [extended key](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#extended-keys) はこう。

* extended private key は前半 256 bit が private key で後半 256 bit が chain code
* extended public key は前半 256 bit がその public key で後半 256 bit が chain code

### fingerprint

* [Key identifiers](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers)

階層として 1つ上の extended public key を HASH160 した先頭 4バイトを fingerprint と呼ぶ。  
ただし master key の場合は `00000000` を使用する。

### シリアライズ

| name | length | note |
| ---- | ---- | ---- |
| [version bytes](#prefix-と-version-bytes) | 4 |  |
| depth | 1 | |
| [fingerprint](#fingerprint) | 4 | |
| child number | 4 | |
| [chain code](#master-key-と-chain-code) | 32 | |
| privkey or pubkey | 33 | privkey は先頭に `00` を付ける |

#### prefix と version bytes

| type | mainnet private | mainnet public | testnet private | testnet public |
| ---- | ---- | ---- | ---- | ---- |
| [P2PKH](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#serialization-format) | `xprv`(`0x0488ade4`) | `xpub`(`0x0488b21e`) | `tprv`(`0x04358394`) | `tpub`(`0x043587cf`) |
| [P2WPKH-nested-in-P2SH](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#extended-key-version) | `yprv`(`0x049d7878`) | `ypub`(`0x049d7cb2`) | `uprv`(`0x044a4e28`) | `upub`(`0x044a5262`) |
| [P2WPKH](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#extended-key-version) | `zprv`(`0x04b2430c`) | `zpub`(`0x04b24746`) | `vprv`(`0x045f18bc`) | `vpub`(`0x045f1cf6`) |
| [P2TR(single key)](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki#test-vectors) | `xprv`(`0x0488ade4`) | `xpub`(`0x0488b21e`) | `tprv`(`0x04358394`) | `tpub`(`0x043587cf`) |

## 関連ページ

* [bitcoind](./bitcoind.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
* [Output Descriptors](./descriptors.md)
