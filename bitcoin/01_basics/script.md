---
layout: "record"
title: "スクリプト"
tags:
  - bitcoin
daily: false
date: "2025/04/15"
---

## はじめに

Bitcoin スクリプトは高級プログラミング言語というよりもアセンブラ言語に近いところがある。  
逆ポーランド法のように、計算したいデータをスタックに載せた後に演算命令を実行すると結果がスタックに載る。  
トランザクションのデータはほとんど参照できず、当然インターネットでデータを取得することもできない。

そういった特徴があるので、よく使われているスクリプトを調査してから自分のスクリプトを作っていくのが良いだろう。  
また、スクリプトを作り間違えて解けないスクリプトに支払ってしまうと、その Bitcoin はどうやっても取り戻すことができなくなる。  
十分に注意が必要である。

## ドキュメント

* [Script - Bitcoin Wiki](https://en.bitcoin.it/wiki/Script)
* [Bitcoin Script - A Mini Programming Language](https://learnmeabitcoin.com/technical/script/)

## デバッグツール

* [btcdeb](../tools/btcdeb.md)

## 正常終了の条件

* scriptPubKey と redeemScript の対応が取れている(スクリプトを実行する条件)
* スクリプトが途中で Fail にならず最後まで終わっている
* スタックの一番上に非ゼロのデータが載っている
* スタックにデータが 1つだけ載っている(segwit以降)

スタックが 1つだけになっているという条件は segwit が有効になったときに加わったものだそうだ。  
`SCRIPT_VERIFY_CLEANSTACK` というフラグがあるそうだが、これは Bitcoin Core の実装で使っているフラグのようだから外からは分からないように思う(ChatGPTに聞いた)。

## 関連ページ

* [value](./value.md)
* [ブロック](/.blocks.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
