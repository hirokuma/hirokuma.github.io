---
layout: record
title: "Blockstream/esplora"
tags:
  - 
daily: false
date: "2025/07/16"
---

[repository](https://github.com/Blockstream/esplora)

_2025/07/16_: commit_id=`52de3ccf39c56ff839e26829ccd6d18f169832f7`

## 用途

[Blockstream/electrs](electrs-bs.md)を使ったブロックエクスプローラー。

## インストール

```console
$ git clone https://github.com/Blockstream/esplora && cd esplora
$ npm install
```

Dockerコンテナ版もあるが、Bitcoin regtestで試したところBitcoinノードとElectrsも一緒に起動した。
私の用途に合わなかったのでそれ以上試していない。

## 実行

Elctrs の REST API が `http://localhost:3002/` で動いている場合はこうなる。  
環境変数の終わりは `/` を付けること。

```console
# Don't forget last "/"
$ export STATIC_ROOT=http://localhost:5000/
$ export API_URL=http://localhost:3002/
$ npm run dev-server
```

`STATIC_ROOT`がブラウザでアクセスするURLである。  
別PC だった場合はこれに IPアドレスなどを設定するとよさそうなのだが、"Unexpected token" で500エラーになる。  
おそらくこのissueと同じだろうが、まだOPENのままだった。

* [Getting an error when accessing esplora site. · Issue #487 · Blockstream/esplora](https://github.com/Blockstream/esplora/issues/487)

Electrs を立ち上げたPC が headless の Raspberry Pi3 だったのでブラウザが使えないから外部からアクセスできるようにしようとしているのであった。

それをあきらめ、Electrs にアクセスする`API_URL`を別PC で動かしている URL にして Esplora 自体はブラウザが使用できる PCで立ち上げようと考えた。  
が、これはこれで CORS がうんぬんということでエラーになった。  
開発サーバの設定に`CORS_ALLOW`があるのでURLだったり"*"だったりを書いてみたのだが、どうにも解決しなかった。

* [Development server options](https://github.com/Blockstream/esplora?tab=readme-ov-file#development-server-options)
