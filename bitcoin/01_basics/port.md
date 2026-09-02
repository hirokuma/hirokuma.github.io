---
layout: "record"
title: "標準ポート番号"
tags:
  - bitcoin
daily: false
date: "2025/07/13"
---

bitcoind がデフォルトで使用するポート番号を以下に示す。  
ZMQ はポート番号指定が必要(デフォルトがない)なので記載していない。

| network | P2P | P2P(onion) | RPC |
| -- | -- | -- | -- |
| mainnet | 8333 | 8334 | 8332 |
| testnet3 | 18333 | 18334 | 18332 |
| testnet4 | 48333 | 48334 | 48332 |
| signet | 38333 | 38334 | 38332 |
| regtest | 18444 | 18445 | 18443 |

## ポート番号を使ったRPCの呼び出し方

```shell
$ bitcoin-cli -rpcconnect=127.0.0.1 -rpcport=18443 -rpcuser=testuser -rpcpassword=testpassword getblockcount
```

```shell
$ curl --user testuser:testpassword --json '{"jsonrpc":"2.0", "id":"curltest", "method":"getblockcount", "params":[]}' http://127.0.0.1:18443
{"jsonrpc":"2.0","result":201,"id":"curltest"}
```

* [curlの–jsonオプション - hiro99ma blog](https://blog.hirokuma.work/2026/02/20260212-other.html)
