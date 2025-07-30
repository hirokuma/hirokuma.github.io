---
layout: "record"
title: "Bitcoin library: C/C++"
tags:
  - bitcoin
  - library
daily: false
date: "2025/07/22"
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
$ time make check
...
real    0m51.198s
user    0m52.676s
sys     0m0.128s
$ sudo make install
```

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

## libwally-core

[repository](https://github.com/ElementsProject/libwally-core)

_2025/07/22_: v1.4.0

```console
$ git clone https://github.com/ElementsProject/libwally-core.git
$ cd libwally-core
$ git checkout -b v1.4.0 refs/tags/release_1.4.0
$ ./tools/autogen.sh
# no Elements API, use only standard secp256k1 API
$ ./configure --enable-minimal --disable-elements --enable-standard-secp --with-system-secp256k1
$ make
$ sudo make install
```

### 備考

* `pkg-config --cflags --libs wallycore`
* `--prefix=$HOME/.local` などとするとインストール先を変更できる。
  * install に `sudo` はいらないので楽だと思うが、それ以外のことが面倒になるので、ここは好みで。
    * include path や library の置き場所が標準ではないのでビルド時などに指定が必要になるなど
      * `-I${HOME}/.local/include -L ${HOME}/.local/lib -lwallycore -lsecp256k1`
* `--enable-standard-secp --with-system-secp256k1` として Blockstream の libsecp256k1-zkp を使わないようにしている

## libbitcoin(C++)

[repository](https://github.com/libbitcoin/libbitcoin-system)

_2025/07/22_: v3.8.0

### 備考

* リリースバージョンは 2023年からv3.8.0のままだが`master`ブランチは更新されている
* v3.8.0 では P2TR をサポートしていなかったのでこれ以上調べていない
