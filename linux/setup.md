---
layout: record
title: "Linuxセットアップ"
tags:
  - linux
daily: false
date: "2025/08/26"
---

## はじめに

Linux 環境を作ったときに行っておきたい設定。  
私が WSL2 でやっておきたいだけのメモです。

## rc

### PS1

WSL2 Ubuntu を主に使っているが、コンソールのプロンプトが `ユーザ名@マシン名 ディレクトリ名 $ ` みたいになっている。  
私の場合はブログで貼り付けたりするので、あまり名前などは載ってほしくない。  
現在のディレクトリ名だけでよい。

```bash
PS1='\[\033[01;33m\]\w\[\033[0;32m\]\$\[\033[00m\] '
```

### LD_LIBRARY_PATHとPKG_CONFIG_PATH

`make install` で `/usr/local/` に置きたくないときがあって、そういうときに `$HOME/.local/` に置いている。  
ライブラリの読み込みだけなら `LD_LIBRARY_PATH` で、`pkgconfig` で `CFLAGS` などを設定したければ `PKG_CONFIG_PATH` も設定する。  
検索パスなので、設定していても負担にはなるまい(たぶん)。

```bash
export LD_LIBRARY_PATH=$HOME/.local/lib
export PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig:/usr/local/lib/pkgconfig
```

### ベルを鳴らさない

他にもあると思うがよく鳴らしてしまうところだけ。

* `~/.inputrc`

```rc
set bell-style none
```

* `~/.vimrc`

```rc
set belloff=all
```

## build-essential

```bash
sudo apt install build-essential
```

C/C++ のコンパイルと make はできるようになりそうだ。
CMake は含まれていない。

```shell
$ apt show build-essential
......
Depends: libc6-dev | libc-dev, gcc (>= 4:12.3), g++ (>= 4:12.3), make, dpkg-dev (>= 1.17.11)
......
```

<small>
いつも "build-essentials" と "s" を付けるかどうかで迷い、
英語圏は単数/複数に厳しいから付けるだろう、とやってエラーになる。
なんで付けないんだろう？
</small>

## jq

```bash
sudo apt install jq
```

## Git

### 名前とメールアドレス

初めて commit しようとしたときにエラーになって気付くから意識しなくてもよいとは思う。  
仕事で別のアカウントで作業することもあるだろうから、そういうときはわざと設定せず、`--global` をつけずリポジトリごとに付けるようにすると良いだろう。

```console
$ git config --global user.name "ほげほげ"
$ git config --global user.email "はにゃはにゃ"
```

### デフォルトブランチ

特に呼び名にこだわりはないので、よく使われているし短いしで "main" にしておく。

* [Git - git-init Documentation](https://git-scm.com/docs/git-init#_configuration)

```bash
git config --global init.defaultBranch main
```

## protoc

### protoc

*  [Releases · protocolbuffers/protobuf](https://github.com/protocolbuffers/protobuf/releases)

### protoc-gen-go, protoc-gen-go-grpc

`$HOME/go/bin/` にインストールされる。

* [Quick start - Go - gRPC](https://grpc.io/docs/languages/go/quickstart/)

```
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### protoc-gen-validate

* [Releases · bufbuild/protoc-gen-validate](https://github.com/bufbuild/protoc-gen-validate/releases)

## PostgreSQL

### ユーザ(role)の追加

インストール直後は `postgres` ユーザしか扱えないようなので、一旦 `su` で `postgres` になりきる。

```bash
sudo su postgres
```

```bash
ROLE="アクセスさせたいアカウント"
PASS="あなたの使いたいパスワード"
echo "CREATE ROLE ${ROLE} CREATEDB LOGIN;" | psql
echo "ALTER ROLE ${ROLE} with PASSWORD '${PASS}';" | psql #パスワードを付けないなら不要(NULLで削除)
```

```bash
ROLE="削除したいアカウント"
echo "DROP ROLE ${ROLE};" | psql
```
