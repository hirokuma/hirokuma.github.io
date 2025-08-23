---
layout: "record"
title: "Bitcoin Core(bitcoind) のビルド"
tags:
  - bitcoin
daily: false
date: "2025/02/19"
---


## リポジトリ

* [bitcoin/bitcoin at v28.1](https://github.com/bitcoin/bitcoin/tree/v28.1)

## ビルド

### 前準備

* [Linux Distribution Specific Instructions - v28.1](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#linux-distribution-specific-instructions)

```console
$ sudo apt-get install \
  build-essential \
  libtool \
  autotools-dev \
  automake \
  pkg-config \
  bsdmainutils \
  python3 \
  libevent-dev \
  libboost-dev \
  libsqlite3-dev
```

[ZMQ](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/zmq.md) を使うなら `libzmq3-dev` もいるだろう。
私の環境ではインストールしていない状態でビルドしたところ、`zmqpubrawblock` を設定してもエラーにならずにポートが開いていなかったので無視されたようだ。

DB をどうするか悩むかもしれない。  
新規環境だったりウォレットが無いのであればそのままにして、既に使っているウォレットがあるなら [Berkeley DB](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#berkeley-db) を使うとよいだろう。
`mainnet` では内蔵のウォレットを使わない方がよいだろう。

### Clone and Build

適当な場所に clone してリリースタグを checkout する。  
`master` を使いたいかもしれないので、その辺りは自身の判断で。

```console
$ git clone https://github.com/bitcoin/bitcoin.git
$ cd bitcoin
$ git checkout -b v28_1 refs/tags/v28.1
```

ビルドは `configure` のオプションを指定して `make` する。  
オプションはいろいろあるので `configure --help` で確認すると良い。
GUI無しで `$HOME/.local` にインストールするならこういう感じだ。

* [bitcoin/doc/build-unix.md at v28.1 · bitcoin/bitcoin](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#to-build)

```console
./autogen.sh
./configure --prefix=$HOME/.local --without-gui
make
make install
```
