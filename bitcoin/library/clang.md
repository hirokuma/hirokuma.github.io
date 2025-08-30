---
layout: "record"
title: "Bitcoin library: C/C++"
tags:
  - bitcoin
  - library
daily: false
date: "2025/08/02"
---

## はじめに

いくつかツールのインストールがいるだろう。

```console
$ sudo apt install build-essential pkg-config libtool
```

## libsecp256k1

[repository](https://github.com/bitcoin-core/secp256k1)

_2025/07/22_: v0.7.0

```console
$ git clone https://github.com/bitcoin-core/secp256k1.git
$ cd secp256k1
$ git checkout -b v0.7.0 refs/tags/v0.7.0
```

### make

makeでは`configure`でオプションを指定する。  
指定できるオプションは`--help`で確認できる。

```console
$ ./configure --help
```

ここではrecoveryを有効にする(libwally-core で使うため)。

```console
$ ./autogen.sh
$ ./configure --enable-module-recovery
$ make
$ make check
$ sudo make install
```

Raspberry Pi3 で `make` は 6分半程度、`make check` は 11分半程度だった。

### CMake

CMakeでは`configure`の代わりに`-D`フラグでオプションを指定する。  
指定できるフラグは`-B build -LH`で確認できる。

```console
$ cmake -B build -LH
```

ここではrecoveryを有効にする。  
なお、v0.7.0のREADMEでは`-DSECP256K1_ENABLE_MODULE_SCHNORRSIG=ON`が例になっているが、シュノア署名はデフォルトで有効になっている。

```console
$ cmake -B build -DSECP256K1_ENABLE_MODULE_RECOVERY=ON
$ cmake --build build
$ time ctest --test-dir build
...
real    0m51.536s
user    0m52.444s
sys     0m0.261s
$ sudo cmake --install build
```

インストール先は`/usr/local/lib/`だった。v0.7.0では共有ライブラリは`libsecp256k1.so.6.0.0`になっていた。  
また`/usr/local/lib/cmake/libsecp256k1/`に`*.cmake`というファイルもあった。

### 補足

* `pkg-config --cflags --libs libsecp256k1`
* libwally-core をビルドした場合、[Blockstream の libsecp256k1-zkp](https://github.com/BlockstreamResearch/secp256k1-zkp) がインストールされるかもしれないので注意すること(同じファイル名になる)

### リンク

* 開発日記
  * [btc: libsecp256k1 は MuSig 2 だった - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250202-btc.html)

## libwally-core

[repository](https://github.com/ElementsProject/libwally-core)

_2025/08/02_: v1.5.0

v1.5.0から `--enable-minimal` と `--with-system-secp256k1` の両方は設定できなくなったようだ。

```console
$ git clone https://github.com/ElementsProject/libwally-core.git
$ cd libwally-core
$ git checkout -b v1.5.0 refs/tags/release_1.5.0
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

### リンク

* 開発日記
  * [btc: libwally-core を使う (1) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250126-btc.html)
  * [btc: libwally-core を使う (2) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250127-btc.html)
  * [btc: libwally-core を使う (3) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250128-btc.html)
  * [btc: libwally-core を使う (4) - hiro99ma blog](https://blog.hirokuma.work/2025/01/20250129-btc.html)
  * [btc: libwally-core で script path (1) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250204-btc.html)
  * [btc: libwally-core で script path (2) - hiro99ma blog](https://blog.hirokuma.work/2025/02/20250205-btc.html)
  * [btc: libwally-core v1.4.0 - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250313-btc.html)

## libbitcoin(C++)

[repository](https://github.com/libbitcoin/libbitcoin-system)

_2025/07/22_: v3.8.0

### 備考

* リリースバージョンは 2023年からv3.8.0のままだが`master`ブランチは更新されている
* v3.8.0 では P2TR をサポートしていなかったのでこれ以上調べていない
