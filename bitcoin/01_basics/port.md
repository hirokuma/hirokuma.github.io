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
