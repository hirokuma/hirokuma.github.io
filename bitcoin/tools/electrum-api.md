---
layout: record
title: "Electrum Server"
tags:
  - bitcoin
daily: false
create: "2026/02/19"
date: "2026/07/28"
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

### 現在のブロック高

直接ブロック高を得るコマンドはなく、"blockchain.headers.subscribe"を呼び出すと現在の情報が即座に返ってくる。
そのまま接続を維持しているとブロックが生成されるたびに通知が届くようになる。

```shell
$ echo '{"jsonrpc": "2.0", "method": "blockchain.headers.subscribe", "params": [""], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":{"height":202,"hex":"00000030d14f03081d0e4f87afc9f470047e9988686cda6f3697aa90dc020e86c156526fd47e588db3b5a9af52e7a57a8e1698f7737e85e388ef8dd87c2afb80f4e2ac438f18686affff7f2000000000"}}
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
* scriptPubKeyの`001493c2ab00863c7891bb4566d991a5b70c01f74b5a`を[cryptii.com](https://cryptii.com/pipes/hash-function/)などでSHA256エンコードして`2a91aa44b9f7d8ebe6f04c0ab4bc200a39635f87c47a0ab9cc0cffde59407616`
* エンディアン逆転して`16764059deff0cccb90a7ac4875f63390a20bcb40a4cf0e6ebd8f7b944aa912a`

```shell
$ echo '{"jsonrpc": "2.0", "method": "blockchain.scripthash.get_history", "params": ["16764059deff0cccb90a7ac4875f63390a20bcb40a4cf0e6ebd8f7b944aa912a"], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":[{"height":204,"tx_hash":"b9449731c81b29d1f04bf477a6b11dccd640165e774478cec8ca9bd938b8528a"},{"height":204,"tx_hash":"d6c769c4c68830822f53a0e8750b7ddde66a9641807fd38aadb5c8cd66e29f92"}]}
```

* [btc: blockchain.scripthash.get_historyの挙動 - hiro99ma blog](https://blog.hirokuma.work/2026/07/20260720-btc.html)

### confirmation数の取得

TXIDからconfirmation数を得るには、APIがサポートしているなら[blockchain.transaction.get](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get)の第2引数 `verbose` を `true` にするとよい。  
がバージョン1.2以降でもサポートされていない場合が多い。
例えばこちらはblockstream/electrsをregtestで動かしている場合である。

```shell
$ echo '{"jsonrpc": "2.0", "method": "blockchain.transaction.get", "params": ["19b190ae1eb1cb746d3d5df260ff44539d8a6199b0e83ce6eb531e3fd17c3e41"], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":"02000000000101b244dbd7d3bf582ccbf556ce6dff5526d07270db3be514a4c54238164242183d0000000000fdffffff027310102401000000160014f1ea7ba1958887b20dd17a5df38e3dc00d8eb86900e1f50500000000160014130c2fbc38e886f18c77392123b832dc64e406720247304402203800dc5fd64413314bdf9c867a21b54079e097b84f74a9a7c41d9f83e388ad9302201b3e3a8dde44ef1356e04883aec5d7da6388c42b02ced9f049e7de1c80878c97012103ca6c4e1b5908b81252fcd4e39544db11be78d2bece33244418755184dde04173c9000000"}

$ echo '{"jsonrpc": "2.0", "method": "blockchain.transaction.get", "params": ["19b190ae1eb1cb746d3d5df260ff44539d8a6199b0e83ce6eb531e3fd17c3e41",true], "id": 0}' | socat - TCP4:localhost:50001
{"error":"verbose transactions are currently unsupported","id":0,"jsonrpc":"2.0"}
```

直接得られない場合は遠回りな方法を使うことになるだろう。

1. トランザクションのvoutから検索に使うscriptHashを選ぶ
1. [blockchain.scripthash.get_history](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-scripthash-get-history)でリストを取得
1. リストの中から該当するTXIDと承認されたheightのセットを探す
1. 現在のブロック高を求める
1. 現在のブロック高から承認されたheightを引いて+1するとconfirmation数になる

最後の+1は忘れやすいので注意。

```shell
# 上で確認した 19b1... のvoutにあるアドレス
$ ./bs-regtest-docker.sh getaddressinfo bcrt1qzvxzl0pcazr0rrrh8ysj8wpjm3jwgpnjwqa0dw | jq .scriptPubKey
"0014130c2fbc38e886f18c77392123b832dc64e40672"

# SHA256(0014130c2fbc38e886f18c77392123b832dc64e40672) => e9102aa83936b931097da7e4672e4b3794dd78b7439a441201f6227ce91d256c

# get_history
$ echo '{"jsonrpc": "2.0", "method": "blockchain.scripthash.get_history", "params": ["6c251de97c22f60112449a43b778dd94374b2e67e4a77d0931b93639a82a10e9"], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":[{"height":202,"tx_hash":"19b190ae1eb1cb746d3d5df260ff44539d8a6199b0e83ce6eb531e3fd17c3e41"}]}

# 現在のブロック高
$ echo '{"jsonrpc": "2.0", "method": "blockchain.headers.subscribe", "params": [""], "id": 0}' | socat - TCP4:localhost:50001
{"id":0,"jsonrpc":"2.0","result":{"height":202,"hex":"00000030d14f03081d0e4f87afc9f470047e9988686cda6f3697aa90dc020e86c156526fd47e588db3b5a9af52e7a57a8e1698f7737e85e388ef8dd87c2afb80f4e2ac438f18686affff7f2000000000"}}

# get_historyでブロック高202、subscribeで202だったので、202(現在) - 202(confirmed) + 1 = 1 conf している、となる
```

## 主なElectrum Protocol実装

おそらく今はRust言語で実装したelectrs系が多いと思う。  
プロトコルの管理をしているのはElectrum Walletなどを出しているspesmiloである。

* [spesmilo/electrumx](https://github.com/spesmilo/electrumx)
  * [spesmilo/electrum-protocol: client-server JSON-RPC protocol for bitcoin light clients](https://github.com/spesmilo/electrum-protocol)
* [romanz/electrs](./electrs.md)
* [Blockstream/electrs](./electrs-bs.md)
* [mempool/electrs](./electrs-ms.md)
