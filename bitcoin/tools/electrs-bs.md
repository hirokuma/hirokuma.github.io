---
layout: "record"
title: "Blockstream/electrs"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/07/13"
---

[repository](https://github.com/Blockstream/electrs)

最初はタグを付けていたようだが、今はブランチ`new-index`をビルドしている。

## 用途

オリジナルの[romanz/electrs](./electrs.md)をベースにしている。

Electrm Server APIだけでなく[Esplora HTTP API](https://github.com/blockstream/esplora/blob/master/API.md)も使用できる。

## インストール

* [Installing & indexing](https://github.com/Blockstream/electrs?tab=readme-ov-file#installing--indexing)

書いてあるのは`cargo run`なので、そのままだと実行される。  
単にビルドするだけであればこの程度で良いだろう。

```console
$ cargo build --release --bin electrs

# 実行ファイルをパスが通ったところにコピー
$ cp target/release/electrs ~/.local/bin/
```

Raspberry Pi3 を新規立ち上げした環境でビルドした。  
Rust だけでなく`clang`がインストールされていないとビルドエラーになる。  
`cmake`も必要らしいが、私の時にはなくてもビルドできたようだ。  
また`ulimit -n 100000`などしてオープンできるファイル数を拡大しておくことを推奨している。

Raspberry Pi3 だったためか非常に時間がかかった。

## 実行

`config.toml`は使わず引数ですべて指定する。  
`--cookie`は、未設定なら`~/.bitcoin/.cookie`から読むが、そうでなければ`"<rpcuser>:<rpcpassword>"`を設定する。
なので`rpcauth`でなくても使えるのかもしれないが確認はしていない。

`--cors`の設定は必要に応じて変更する。  
ここでは[esplora](./esplora.md)から呼び出される

```console
$ electrs --db-dir="/mnt/usb/electrs-data" \
    --network="regtest" \
    --cookie="testuser:testpass"  \
    --electrum-rpc-addr="localhost:50001" \
    --http_url="localhost:3002" \
    --cors="http://localhost:5000"
```

[Electrum Protocol](https://electrumx.readthedocs.io/en/latest/protocol.html)が使用できるようになっていればOK。

```console
$ echo '{"jsonrpc": "2.0", "method": "server.version", "params": ["", "1.4"], "id": 0}' | netcat 127.0.0.1 50001
{"id":0,"jsonrpc":"2.0","result":["electrs-esplora 0.4.1","1.4"]}
```

[Esplora API](https://github.com/blockstream/esplora/blob/master/API.md)も使用できる。  
アドレスは`electrs`起動時のログで`http_addr`を見ると良い。

```console
$ curl http://127.0.0.1:3002/block-height/1
79900ad51d7e6a8aed2a17570dd5a324134693af6e59df973f6a3bec16de12a5
```
