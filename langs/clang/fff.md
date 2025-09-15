---
layout: "record"
title: "clang: テストフレームワーク fff"
tags:
  - clang
  - tools
daily: false
date: "2025/07/08"
---

## 概要

C言語のテストフレームワーク fff を紹介する。

* [meekrosoft/fff: A testing micro framework for creating function test doubles](https://github.com/meekrosoft/fff)

[fff.h](https://github.com/meekrosoft/fff/blob/master/fff.h)を見ると分かるが、
引数の数が異なるマクロがたくさんある。  
そうすることでよほど引数が多い関数でなければ fake 関数に置き換えることができる。

## 最近のサンプル(2023年)

2025/07/08時点で fff の最新版は 2023年5月である。

* [2023年版fff](https://github.com/meekrosoft/fff/tree/5111c61e1ef7848e3afd3550044a8cf4405f4199)

それに合わせて更新した fff の使用例である。  
下にある 2021年版をビルドが通るように更新しただけなので見栄えはよろしくない。

* [hirokuma/fff_examples at d67e16b11f7c9297ffbff90e77e6fe5d66f4ba93](https://github.com/hirokuma/fff_examples/tree/d67e16b11f7c9297ffbff90e77e6fe5d66f4ba93)

```console
$ make test
./build/tst
Running main() from /home/xxx/fff_examples/tests/fff/build/_deps/googletest-src/googletest/src/gtest_main.cc
[==========] Running 9 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 9 tests from test
[ RUN      ] test.open_1
[       OK ] test.open_1 (0 ms)
[ RUN      ] test.open_2
[       OK ] test.open_2 (0 ms)
[ RUN      ] test.open_3
[       OK ] test.open_3 (0 ms)
[ RUN      ] test.close_1
[       OK ] test.close_1 (0 ms)
[ RUN      ] test.close_2
[       OK ] test.close_2 (0 ms)
[ RUN      ] test.access_1
[       OK ] test.access_1 (0 ms)
[ RUN      ] test.access_2
[       OK ] test.access_2 (0 ms)
[ RUN      ] test.access_3
[       OK ] test.access_3 (0 ms)
[ RUN      ] test.access_4
[       OK ] test.access_4 (0 ms)
[----------] 9 tests from test (0 ms total)

[----------] Global test environment tear-down
[==========] 9 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 9 tests.
```

fff は CMakeを使うようになっているのだが、私が対応できていないのでそのままだ。  
gtest のヘッダファイルやライブラリも`find`でファイルを探したくらいなのでちゃんとしたやり方ではないだろう。

## 古いサンプル

こちらは2021年に私が作っていた fff の使用例である。  
fff はインストールするタイプではなく `fff.h` をインクルードして使うので、プロジェクトの中に `fff` を取り込んでいる。
今思えば git modules で取り込めばよかったと思う。

* [hirokuma/fff_examples: FFFを使った例](https://github.com/hirokuma/fff_examples/tree/6d2acba6a3e9564114e2bc8c2654ce0b77a03587)

当時の fff は[このような構成](https://github.com/meekrosoft/fff/tree/7e09f07e5b262b1cc826189dc5057379e40ce886)で、gtest が入っていた。
