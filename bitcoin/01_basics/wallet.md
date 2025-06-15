# ウォレット

_最終更新日: 2025/03/24_

## HDウォレット

* [BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
* [BIP-44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)

(ここに階層の図を入れる)

### seed

seed は 128～512 bits の乱数である。  
BIP-32 では 256 bit を推奨していたが今もそうなのかは未確認。

### master key と chain code

*　[Master key generation](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#master-key-generation)

Key="Bitcoin seed"、Data=seed で HMAC-SHA512 計算をした値を `I` とし、それを半分に割って <code class="language-plaintext highlighter-rouge">I<sub>L</sub></code>、<code class="language-plaintext highlighter-rouge">I<sub>R</sub></code> とする(左半分と右半分)。  
左半分が master secret key、右半分が master chain code である。  
<code class="language-plaintext highlighter-rouge">I<sub>L</sub></code> が 0 と等しいか `n` 以上だと NG。

### 拡張鍵

[extended key](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#extended-keys) はこう。

* extended private key は前半 256 bit が private key で後半 256 bit が chain code
* extended public key は前半 256 bit がその public key で後半 256 bit が chain code

#### シリアライズ

プレフィクス

* P2PKH?: `xprv`, `xpub` ([BIP-32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#serialization-format))
* P2WPKH-nested-in-P2SH: `yprv`, `ypub` ([BIP-49](https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki#extended-key-version))
* P2WPKH: `zprv`, `zpub` ([BIP-84](https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki#extended-key-version))
* P2TR(single key): `xprv`, `xpub` ([BIP-86](https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki#test-vectors))

### 参考

* 開発日記
  * [btc: ニモニック](https://blog.hirokuma.work/2025/03/20250324-btc.html)

## Output Descriptors

under construction...

* [BIP-380](https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki)

### 参考

* 開発日記
  * [btc: Output Descriptors](https://blog.hirokuma.work/2025/02/20250224-btc.html)
  * [btc: Output Descriptors (2)](https://blog.hirokuma.work/2025/02/20250225-btc2.html)
  * [btc: Output Descriptors (3)](https://blog.hirokuma.work/2025/03/20250301-btc.html)
  * [btc: Output Descriptors (4)](https://blog.hirokuma.work/2025/03/20250302-btc.html)
  * [btc: Output Descriptors (5)](https://blog.hirokuma.work/2025/03/20250303-btc.html)

## 関連ページ

* [bitcoind](./bitcoind.md)
* [ブロック](/.blocks.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
