---
layout: record
title: "シェル起動時に読み込む順番(bash)"
tags:
  - linux
daily: false
create: "2026/02/04"
date: "2026/02/04"
---

普段bashを使っている。  
シェルを立ち上げると `~/.bashrc` が実行されるのはわかるのだが他が曖昧なのでメモしておく。  

## 基本

* `/etc/profile`
* 以下の順番で最初に見つかったファイルを実行
  * `~/.bash_profile`
  * `~/.bash_login`
  * `~/.profile`

## Ubuntu 24.04

デフォルトではこうなっていた。
`/etc/profile` についてはそれより下の確認はしていない。

* `/etc/profile`
  * `/etc/bash.bashrc`
  * `/etc/profile.d/*.sh`
* `~/.bash_profile`
  * `~/.profile`
    * `~/.bashrc`
