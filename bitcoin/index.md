# Bitcoin調査

Bitcoin技術に関する調査メモを残すページ。  
投資などは対象外です。

## はじめに

Bitcoin技術は更新が続いているので、ここに書いたことも「当時は正しかったかもしれないが」ということになるかもしれない。  
読む人も注意して、記事を信用しないように。  
よく言われる「Don't trust, verify」というやつである。

最終的には「プログラムで書かれているのでそれを解読するのが正しい」になってしまうが、そんなことをしていたら時間がいくらあっても足りなくなる。
なので、その人が言っているのと別の情報源から確認することが多くなるだろう。

実際にコーディングする場合は信用できるライブラリだけを使うようにしよう。  
まったくライブラリを使わずにコーディングするのはもはや無理な世界だと思う。

## よく使うページ

### Source codes

* [GitHub: bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
* [GitHub: bitcoin/bips](https://github.com/bitcoin/bips)

### 解説

* [Developer Guides — Bitcoin](https://developer.bitcoin.org/devguide/)
  * [Reference — Bitcoin](https://developer.bitcoin.org/reference/)

* [Learn Me A Bitcoin (By Greg Walker)](https://learnmeabitcoin.com/)

## Basics

* [Bitcoin Core(bitcoind) を regtest で動かす](/bitcoin/01_basics/bitcoind.html)
* [値の表現](/bitcoin/01_basics/value.html)
* [ブロック](/bitcoin/01_basics/blocks.html)
* [トランザクション](/bitcoin/01_basics/transactions.html)

## BIP

* [P2TR および BIP-341周辺](bitcoin/02_bip/bip341.md)
