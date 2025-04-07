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

## 基本

* [Bitcoin Core(bitcoind) を regtest で動かす](/01_basics/bitcoind.md)
* [値の表現](01_basics/value.md)
* [ブロック](01_basics/blocks.md)
* [トランザクション](01_basics/transactions.md)
* [アドレス](01_basics/address.md)
* [ウォレット](01_basics/wallet.md)

## ライブラリ

* [C/C++](library/clang.md)
* [JavaScript/TypeScript](library/js.md)
* [Go](library/go.md)

## ツール

* [btcdeb](tools/btcdeb.md)
* [electrs](tools/electrs.md)
