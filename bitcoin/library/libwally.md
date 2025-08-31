---
layout: "record"
title: "Bitcoin library: libwally-core"
tags:
  - bitcoin
  - library
daily: false
date: "2025/08/31"
---

[repository](https://github.com/ElementsProject/libwally-core)

_2025/08/30_: v1.5.1

## ビルド

v1.5.0から `--enable-minimal` と `--with-system-secp256k1` の両方は設定できなくなったようだ。

```console
$ git clone https://github.com/ElementsProject/libwally-core.git
$ cd libwally-core
$ git checkout -b v1.5.1 refs/tags/release_1.5.1
$ ./tools/autogen.sh
# no Elements API, use only standard secp256k1 API
$ ./configure --disable-elements --enable-standard-secp --with-system-secp256k1
$ make
$ sudo make install
```

### 備考

* `pkg-config --cflags --libs wallycore`
    * `export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig`
* `--prefix=$HOME/.local` などとするとインストール先を変更できる。
  * install に `sudo` はいらないので楽だと思うが、それ以外のことが面倒になるので、ここは好みで。
    * include path や library の置き場所が標準ではないのでビルド時などに指定が必要になるなど
      * `-I${HOME}/.local/include -L ${HOME}/.local/lib -lwallycore -lsecp256k1`
      * `export LD_LIBRARY_PATH=$HOME/.local/lib:/usr/local/lib`
      * `export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:/usr/local/lib/pkgconfig`
* `--enable-standard-secp --with-system-secp256k1` として Blockstream の libsecp256k1-zkp を使わないようにしている

## 使い方

### 引数の順番

だいたい、前半が入力系、後半が出力系になっている。

### エラー

戻り値は `int` 型になっているものが多い。  
種類が少ないし、詳細を取得することもできず、ログを出力するモードもないためデバッグは結構大変である。

```c
/** Return codes */
#define WALLY_OK      0 /** Success */
#define WALLY_ERROR  -1 /** General error */
#define WALLY_EINVAL -2 /** Invalid argument */
#define WALLY_ENOMEM -3 /** malloc() failed */
```

私の場合、わからなかったらライブラリにログ出力を埋め込んでいる。
面倒だが手っ取り早い。

### メモリの解放

いくつかのAPIはメモリを確保して返すものがある。  
そういったメモリは使用後に解放すること。
APIの説明にだいたい書かれていると思う。

私の場合、[valgrind](https://valgrind.org/) で解放漏れをチェックしている。

## リンク

* 開発日記
  * [btc: libwally-core を使う (1) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250126-btc.html)
  * [btc: libwally-core を使う (2) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250127-btc.html)
  * [btc: libwally-core を使う (3) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250128-btc.html)
  * [btc: libwally-core を使う (4) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250129-btc.html)
  * [btc: libwally-core で script path (1) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250204-btc.html)
  * [btc: libwally-core で script path (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250205-btc.html)
  * [btc: libwally-core v1.4.0 - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250313-btc.html)
