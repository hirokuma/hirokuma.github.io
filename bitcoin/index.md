# Bitcoin調査

Bitcoin技術に関する調査メモを残すページ。

## 禁止事項

* このサイトでは Bitcoin の購入を含め、仮想通貨の購入を勧める行為はしません
  * 売買するのは個人の自由だが、このサイトはそういう目的のために調査しているわけではない

## はじめに

Bitcoin技術は更新が続いているので、ここに書いたことも「当時は正しかったかもしれないが」ということになるかもしれない。  
読む人も注意して、記事を信用しないように。  
よく言われる「Don't trust, verify」である。

最終的には「プログラムで書かれているのでそれを解読するのが正しい」になってしまうが、そんなことをしていたら時間がいくらあっても足りなくなる。
なので、その人が言っているのと別の情報源から確認することが多くなるだろう。

実際にコーディングする場合は信用できるライブラリだけを使うようにしよう。  
まったくライブラリを使わずにコーディングするのはもはや無理な世界だと思う。

## 基本

* [インストール](01_basics/install.md)
* [Bitcoin Core(bitcoind) を regtest で動かす](01_basics/bitcoind.md)
* [値の表現](01_basics/value.md)
* [ブロック](01_basics/blocks.md)
* [トランザクション](01_basics/transactions.md)
* [アドレス](01_basics/address.md)
* [ウォレット](01_basics/wallet.md)
* [txout proof](01_basics/txoutproof.md)

## ライブラリ

* [C/C++](library/clang.md)
* [JavaScript/TypeScript](library/js.md)
* [Go](library/go.md)

## ツール

* [btcdeb](tools/btcdeb.md)
* [romanz/electrs](tools/electrs.md)

### 自作

* [hirokuma/bitcoin-flow-dot](https://github.com/hirokuma/bitcoin-flow-dot/tree/f7665b37d6811d780e439a67ad7b2735a36d560e)
  * 2025/06/15 [btc: トランザクションのつながり図](2025/06/20250615-btc.md)

## リンク集

### Source codes

* [GitHub: bitcoin/bitcoin](https://github.com/bitcoin/bitcoin)
* [GitHub: bitcoin/bips](https://github.com/bitcoin/bips)

### 解説

* [Developer Guides — Bitcoin](https://developer.bitcoin.org/devguide/)
  * [Reference — Bitcoin](https://developer.bitcoin.org/reference/)

* [Learn Me A Bitcoin (By Greg Walker)](https://learnmeabitcoin.com/)

## その他

### 回想

私が Bitcoin のことを勉強し始めた頃、定期的(数ヶ月くらい)に「Bitcoin は終わった」「Bitcoin は死んだ」という記事が出ていた。
当時の私はものすごく心配した。

永らく組み込みソフトウェアの開発をしていたのだが、使っていた技術についてそのように強い口調の記事を見たことがなかったからだ。
せいぜい、その技術は広まらない、とか、こちらの技術の方がよい、というような感じだった。
その論調も感情的では無く、その記事を書いた会社がメインとしていた技術と対抗していたということがあったとしても、
相手の技術を否定するよりも勧めたい技術の利点を挙げる感じがして好感が持てた。

しかしこの業界、仮想通貨業界というよりも金融業界になるのかもしれないが、まったく違う。  
大半・・・ほとんどがよくわからない根拠で相手をけなし、よくわからない根拠で自分をほめる、みたいな感じだ。  
そしてこの業界に関係するのが、自分らなりの理想を持った開発集団、国家を中心にした法律とその周辺、既得権益を持ったものすごく力のある勢力とその周辺、金融商品を扱うサービス、一発逆転を狙うスタートアップ、隙を突いた詐欺集団、などなど、通常なら顔を合わせない面々が勢揃いしている。

### 

一介のフリーランスエンジニアとして言えることはあまりない。  
技術側としては、詐欺行為を行わないことと詐欺に加担しないようにすること、くらいである。

心理的なものについては知らん。  
テレビショッピングと同じで、買ってもらうことでメリットがあるから紹介するのだと思えば購入熱は下がるんじゃなかろうか。  
面倒なのは、親切にしてもらって断りづらい、というタイプだ。  
これはどうするのがよいかよくわからないが、とにかく即答を避けて、あとは逃げ回るのがよいと思う。
対面するのを避け、通信するのを避け、見て見ぬふりをする。  
身近な人物相手だと難しいと思う。
