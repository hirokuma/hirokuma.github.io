---
layout: "record"
title: "clang: テストフレームワーク fff"
tags:
  - clang
daily: false
date: "2025/07/07"
---

## 概要

C言語のテストフレームワーク fff を紹介する。

* [meekrosoft/fff: A testing micro framework for creating function test doubles](https://github.com/meekrosoft/fff)

[fff.h](https://github.com/meekrosoft/fff/blob/master/fff.h)を見ると分かるが、
引数の数が異なるマクロがたくさんある。  
そうすることでよほど引数が多い関数でなければ fake 関数に置き換えることができる。

## 古いサンプル

こちらは2021年に私が作った fff の使用例である。  
fff はインストールするタイプではなく `fff.h` をインクルードして使うので、プロジェクトの中に `fff` を取り込んでいる。
今思えば git modules で取り込めばよかったと思う。

* [hirokuma/fff_examples: FFFを使った例](https://github.com/hirokuma/fff_examples/tree/6d2acba6a3e9564114e2bc8c2654ce0b77a03587)

当時の fff は[このような構成](https://github.com/meekrosoft/fff/tree/7e09f07e5b262b1cc826189dc5057379e40ce886)で、gtest が入っていた。
