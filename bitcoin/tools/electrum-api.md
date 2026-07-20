---
layout: record
title: "Electrum Server"
tags:
  - bitcoin
daily: false
create: "2026/02/19"
date: "2026/07/19"
---

Bitcoin Coreはフルノードでブロック情報をすべて持っている(pruneしていなければ)。  
その分、運用は重たい。  
またアプリを作って動かすために利用しようとしても、
LAN内であればBitcoin CoreのJSON-RPC APIを使えばよいがモバイルアプリなどからは使いづらい。

そういう経緯があったかどうかは知らないが、
Electrum ServerはBitcoin Coreの外側に立ち、Electrum Protocolを提供するサーバである。

## Electrum Protocol

* [Protocol Methods — ElectrumX ElectrumX 1.20.2 documentation](https://electrumx.readthedocs.io/en/latest/protocol-methods.html)
* [Electrum Protocol — electrum-protocol Electrum Protocol 1.7.x documentation](https://electrum-protocol.readthedocs.io/en/latest/)

### ⚠バージョンに注意

上にリンクを2つ載せているが、どちらもプロトコルバージョンを指定したリンクがない。  
今実装されているプロトコルバージョンはv1.4が一番多いと思われる(2026/07月の感想)。  

例えば、v1.7のドキュメントに`blockchain.scriptpubkey.get_history`があったのだが、
これはそれまで`blockchain.scripthash.get_history`という名前だった。  
頭の中で"get_history"だけ覚えていて調べると存在しないメソッド名のほうが見つかることがあるのだ。

### APIアクセス

コマンドはJSON-RPCなのだがレスポンスはHTTPではなく素のTCPで返ってくる。
そのため `curl --json` などではうまく扱うことができない。  
`socat` はRaspberry Piでは `sudo apt install socat` でインストールした。  
`netcat` でもよいが待機状態になるため `-N` をつけるか、使えないなら `-w 1` などとして自動切断するとよい。

```shell
$ echo '{"jsonrpc": "2.0", "method": "server.version", "params": ["", "1.4"], "id": 0}' | socat - TCP4:192.168.0.30:50001
{"id":0,"jsonrpc":"2.0","result":["electrs/0.10.9","1.4"]}
```

ブロックチェーンのデータにアクセスできることも見ておく。  
[blockchain.block.header](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-block-header) はこう。  
`cp_height` を付けるとエラーになるが[electrumがそうだから](https://github.com/romanz/electrs/issues/1080)だそうだ。

```shell
 $ echo '{"jsonrpc": "2.0", "method": "blockchain.block.header", "params": [5], "id": 0}' | socat - TCP4:192.168.0.30:50001
{"id":0,"jsonrpc":"2.0","result":"0100000085144a84488ea88d221c8bd6c059da090e88f8a2c99690ee55dbba4e00000000e11c48fecdd9e72510ca84f023370c9a38bf91ac5cae88019bee94d24528526344c36649ffff001d1d03e477"}
```

`bitcoin-cli` で確認するとデータは一致している。

```shell
$ bitcoin-cli getblockhash 5
000000009b7262315dbf071787ad3656097b892abffd1f95a1a022f896f533fc
$ bitcoin-cli getblockheader 000000009b7262315dbf071787ad3656097b892abffd1f95a1a022f896f533fc false
0100000085144a84488ea88d221c8bd6c059da090e88f8a2c99690ee55dbba4e00000000e11c48fecdd9e72510ca84f023370c9a38bf91ac5cae88019bee94d24528526344c36649ffff001d1d03e477
```

### scriptPubKeyはSHA256して逆転

[blockchain.scripthash.get_history](https://electrumx.readthedocs.io/en/latest/protocol-methods.html#blockchain-scripthash-get-history)などは引数に`scriptPubKey`を取るようになっている。
が、これは純粋な`scriptPubKey`ではなく[sha256した値](https://electrum-protocol.readthedocs.io/en/latest/protocol-basics.html#scriptpubkeys)を使う。
そしてさらにエンディアンを逆転させる。

```shell
$ bitcoin-cli getnewaddress
bcrt1qj0p2kqyx83ufrw69vmverfdhpsqlwj668ge5h4
$ bitcoin-cli getaddressinfo bcrt1qj0p2kqyx83ufrw69vmverfdhpsqlwj668ge5h4 | jq .scriptPubKey
"001493c2ab00863c7891bb4566d991a5b70c01f74b5a"
```

* このアドレスに適当に送金してconfirmさせておく
* `001493c2ab00863c7891bb4566d991a5b70c01f74b5a`を[cryptii.com](https://cryptii.com/pipes/hash-function/)などでSHA256エンコードして`2a91aa44b9f7d8ebe6f04c0ab4bc200a39635f87c47a0ab9cc0cffde59407616`
* エンディアン逆転して`16764059deff0cccb90a7ac4875f63390a20bcb40a4cf0e6ebd8f7b944aa912a`

```shell
$ echo '{"jsonrpc": "2.0", "method": "blockchain.scripthash.get_history", "params": ["16764059deff0cccb90a7ac4875f63390a20bcb40a4cf0e6ebd8f7b944aa912a"], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":[{"height":204,"tx_hash":"b9449731c81b29d1f04bf477a6b11dccd640165e774478cec8ca9bd938b8528a"},{"height":204,"tx_hash":"d6c769c4c68830822f53a0e8750b7ddde66a9641807fd38aadb5c8cd66e29f92"}]}
```

### confirmation数の取得

TXIDからconfirmation数を得るには、APIがサポートしているなら[blockchain.transaction.get](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get)の第2引数 `verbose` を `true` にするとよい。  
サポートされていない場合は遠回りな方法を使うことになるだろう。

1. トランザクションのvoutから検索に使うscriptHashを選ぶ
1. [blockchain.scripthash.get_history](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-scripthash-get-history)でリストを取得
1. リストの中から該当するTXIDと承認されたheightのセットを探す
1. 現在のブロック高を求める
1. 現在のブロック高から承認されたheightを引いて+1するとconfirmation数になる

最後の+1は忘れやすいので注意。

## 主なElectrum Protocol実装

おそらく今はRust言語で実装したelectrs系が多いと思う。

* [romanz/electrs](./electrs.md)
* [Blockstream/electrs](./electrs-bs.md)
* [mempool/electrs](./electrs-ms.md)
* [spesmilo/electrumx](https://github.com/spesmilo/electrumx)
