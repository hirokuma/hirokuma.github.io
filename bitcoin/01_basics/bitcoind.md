---
layout: "record"
title: "Bitcoin Core(bitcoind) を regtest で動かす"
tags:
  - bitcoin
daily: false
date: "2025/11/26"
---

## はじめに

よほど野心的でない限り Bitcoin のフルノードを自作しようとは思わないだろう。  
ここでは最も一般的と思われる Bitcoin Core(bitcoind) のビルドとオプションについてメモを残す。  
Ubuntu 22.04 (WSL2) で確認している。

現時点で Bitcoin Core の最新バージョンは v29.0 のためそれを使っていく。  
以前のバージョン表記は `v0.XX.YY`(v0.21.2まで) だったが、比較的最近から `vXX.YY`(v22.0～) に変わった。
もし「v0.」で始まっている記事があっても、それがものすごく古いとは限らないことは覚えておいて良いだろう。
ただ記事の更新日時が新しいのに「v0.」の場合は単に日付だけ新しいだけなので気をつけよう。  
基本的に、周辺アプリの互換性の都合以外で Bitcoin Core の古いバージョンを使う必要はほぼない。

## Bitcoin Core インストール

[Bitcoin Core(bitcoind) のインストール](./install.md) 参照

## 設定と実行

ノードとして動作する `bitcoind` や 操作する `bitcoin-cli` は設定ファイル `bitcoin.conf` を参照する。  
設定ファイルを使わず引数にしても同じことができるので、その辺りは自身の判断で。

regtest でしか使わないならこんな感じでよいだろう。

```conf
server=1
txindex=1
regtest=1

zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333

[regtest]
#rpcuser=testuser
#rpcpassword=testpass
rpcauth=testuser:90d538109436dcea4d3da67f65d6aa00$21214960fe9d1bbd9d5f40ab16212fe9aa3d87a59e2cfef91232729c5de00657
fallbackfee=0.000001

blockfilterindex=1
peerblockfilters=1
```

`rpcuser` と `rpcpassword` は JSON-RPC で通信したい場合に設定する。

```console
$ curl --user testuser:testpass --data-binary '{"jsonrpc": "2.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: application/json' http://127.0.0.1:18443/
{"jsonrpc":"2.0","result":0,"id":"curltest"}
```

### rpcauth

`rpcuser`と`rpcpassword`は推奨されておらず、[rpcauth](https://github.com/bitcoin/bitcoin/tree/v28.1/share/rpcauth)を使う方が望ましい。

```console
$ ./share/rpcauth/rpcauth.py user pass
String to be appended to bitcoin.conf:
rpcauth=user:<省略>
Your password:
pass
```

出力された `rpcauth` の行を `bitcoin.conf` に貼り付ける。

`rpcauth` は複数設定することができる。  
また、electrs などのツールで参照する cookieファイル(`~/.bitcoin/regtest/.cookie`など)は`rpcauth`を設定した場合しか生成されない。

### 起動

`PATH` が通っていればコマンド名だけで実行できる。  
何も指定しないと `bitcoin.conf` は `$HOME/.bitcoin/bitcoin.conf` が使用され、regtest のデータは `$HOME/.bitcoin/regtest/` 以下に置かれる。

```bash
bitcoind
```

regtest を使っていると最初からやり直したいことがしばしばある。
そういう場合は `$HOME/.bitcoin/regtest/` をディレクトリごと削除するとよい。
mainnet のデータは `$HOME/.bitcoin/` の直下に置かれるので間違えて削除してしまわないよう。

なお、mainnet で Bitcoin Core のウォレットを直接使うのはあまりよろしくないと思う。
間違って削除しやすいし、BIP-39 のようなバックアップもできないはずだ(ちょっと私の知識は古いかも？)。  
どうしてもというときは Spector などを挟むとよいとは思うが、私は使ったことがない。

## ウォレットの作成

デフォルトでは `bitcoind` を立ち上げてもウォレットが存在しない。  
regtest の場合はブロック生成した報酬を使ってテストをするので、ウォレットを作るのが楽である。

```console
$ bitcoin-cli createwallet ""
{
  "name": ""
}
```

ウォレットに受け取り用アドレスを作ってブロック生成する。

```console
$ addr=`bitcoin-cli -regtest getnewaddress`
$ bitcoin-cli -regtest generatetoaddress 150 $addr
$ bitcoin-cli -regtest getbalance
```

## おまけ

私が使っている設定やスクリプト。

* [gist](https://gist.github.com/hirokuma/6a8d1553a813fa569599d5b0f54f722a)

## おまけ(Polar)

[Polar](https://lightningpolar.com/) という、Lightning Network の regtest 環境を立ち上げるプロジェクトがある。  
GUI で操作は比較的簡単である。  
Lightning Network 開発用だが、Bitcoin Core だけを立ち上げることもできる。

## おまけ(Nigiri)

Polar と同じようなプロジェクトで [Nigiri](https://nigiri.vulpem.com/) がある。  
こちらは GUI ではなく CUIで、主に環境の立ち上げを行ってくれる。  
それほど使ったことがないので、ここでは紹介だけしておく。

## おわりに

regtest で `bitcoind` を立ち上げる手順を説明した。

## 関連ページ

* [インストール](./install.md)
* [ウォレット](./wallet.md)
* [ブロック](./blocks.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
