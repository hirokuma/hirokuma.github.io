# スクリプト

_最終更新日: 2025/04/15_

## はじめに

Bitcoin スクリプトは高級プログラミング言語というよりもアセンブラ言語に近いところがある。  
逆ポーランド法のように、計算したいデータをスタックに載せた後に演算命令を実行すると結果がスタックに載る。  
トランザクションのデータはほとんど参照できず、当然インターネットでデータを取得することもできない。

そういった特徴があるので、よく使われているスクリプトを調査してから自分のスクリプトを作っていくのが良いだろう。  
また、スクリプトを作り間違えて解けないスクリプトに支払ってしまうと、その Bitcoin はどうやっても取り戻すことができなくなる。  
十分に注意が必要である。

### ドキュメント

* [Script - Bitcoin Wiki](https://en.bitcoin.it/wiki/Script)
* [Bitcoin Script - A Mini Programming Language](https://learnmeabitcoin.com/technical/script/)

### デバッグツール

* [btcdeb](../tools/btcdeb.md)
