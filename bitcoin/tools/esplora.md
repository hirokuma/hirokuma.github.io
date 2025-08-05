---
layout: record
title: "Blockstream/esplora"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/08/03"
---

## サイト

* [repository: github.com/Blockstream/esplora](https://github.com/Blockstream/esplora)

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

この設定だと`STATIC_ROOT`と`API_URL`が同じ`localhost`ではあるもののポート番号が異なるため[Origin](https://developer.mozilla.org/ja/docs/Glossary/Origin)が別と判断される。
ここでは`STATIC_ROOT`から`API_URL`を呼び出す経路に影響がある。  
関連する設定で、esplora には環境変数`CORS_ALLOW`が、electrs には `--cors`がある。
どちらに対して設定するかというと、「アクセスを許可する」なのでAPIを提供するelectrsに`--cors="http://localhost:5000"`などとして相手を許すようにしておく。

* [CORS(Cross-Origin Resource Sharing) - とほほのWWW入門](https://www.tohoho-web.com/ex/cors.html)

```script
HOST=http://localhost

export CORS_ALLOW="*"
# Don't forget last "/"
$ export STATIC_ROOT=$HOST:5000/
$ export API_URL=$HOST:3002/
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

## その他

regtestでvoutをSpentしたトランザクションにジャンプしたかったのでちょっと改造した(Gemini Code Assist)。

* [hirokuma/esplora](https://github.com/hirokuma/esplora)
