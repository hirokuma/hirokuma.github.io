---
layout: "record"
title: "Blockstream/electrs"
tags:
  - bitcoin
  - tools
daily: false
create: "2025/07/13"
date: "2026/02/18"
---
---

## サイト

* [repository: github.com/Blockstream/electrs](https://github.com/Blockstream/electrs)

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

### help

```console
$ electrs --help
Electrum Rust Server 0.4.1

USAGE:
    electrs [FLAGS] [OPTIONS]

FLAGS:
        --address-search                          Enable prefix address search
        --anonymize-json-rpc-logging-source-ip    enables ip anonymization in rpc logs
        --enable-json-rpc-logging                 turns on rpc logging
    -h, --help                                    Prints help information
        --hide-json-rpc-logging-parameters        disables parameter printing in rpc logs
        --index-unspendables                      Enable indexing of provably unspendable outputs
        --initial-sync-compaction
            Perform compaction during initial sync (slower but less disk space required)

        --jsonrpc-import
            Use JSONRPC instead of directly importing blk*.dat files. Useful for remote full node or low memory system

        --lightmode                               Enable light mode for reduced storage
        --timestamp                               Prepend log lines with a timestamp
    -V, --version                                 Prints version information
    -v                                            Increase logging verbosity

OPTIONS:
        --blocks-dir <blocks_dir>
            Analogous to bitcoind's -blocksdir option, this specifies the directory containing the raw blocks files
            (blk*.dat) (default: ~/.bitcoin/blocks/)
        --cookie <cookie>
            JSONRPC authentication cookie ('USER:PASSWORD', default: read from ~/.bitcoin/.cookie)

        --cors <cors>                                Origins allowed to make cross-site requests
        --daemon-dir <daemon_dir>                    Data directory of Bitcoind (default: ~/.bitcoin/)
        --daemon-parallelism <daemon_parallelism>    Number of JSONRPC requests to send in parallel [default: 4]
        --daemon-rpc-addr <daemon_rpc_addr>
            Bitcoin daemon JSONRPC 'addr:port' to connect (default: 127.0.0.1:8332 for mainnet, 127.0.0.1:18332 for
            testnet3 and 127.0.0.1:48332 for testnet4 and 127.0.0.1:18443 for regtest)
        --db-dir <db_dir>                            Directory to store index database (default: ./db/)
        --electrum-banner <electrum_banner>
            Welcome banner for the Electrum server, shown in the console to clients.

        --electrum-rpc-addr <electrum_rpc_addr>
            Electrum server JSONRPC 'addr:port' to listen on (default: '127.0.0.1:50001' for mainnet, '127.0.0.1:60001'
            for testnet3, '127.0.0.1:40001' for testnet4 and '127.0.0.1:60401' for regtest)
        --electrum-txs-limit <electrum_txs_limit>
            Maximum number of transactions returned by Electrum history queries. Lookups with more results will fail.
            [default: 500]
        --http-addr <http_addr>
            HTTP server 'addr:port' to listen on (default: '127.0.0.1:3000' for mainnet, '127.0.0.1:3001' for testnet3
            and '127.0.0.1:3004' for testnet4 and '127.0.0.1:3002' for regtest)
        --http-socket-file <http_socket_file>
            HTTP server 'unix socket file' to listen on (default disabled, enabling this disables the http server)

        --monitoring-addr <monitoring_addr>
            Prometheus monitoring 'addr:port' to listen on (default: 127.0.0.1:4224 for mainnet, 127.0.0.1:14224 for
            testnet3 and 127.0.0.1:44224 for testnet4 and 127.0.0.1:24224 for regtest)
        --network <network>                          Select network type (mainnet, testnet, testnet4, regtest, signet)
        --precache-scripts <precache_scripts>        Path to file with list of scripts to pre-cache
        --utxos-limit <utxos_limit>
            Maximum number of utxos to process per address. Lookups for addresses with more utxos will fail. Applies to
            the Electrum and HTTP APIs. [default: 500]
        --zmq-addr <zmq_addr>                        Optional zmq socket address of the bitcoind daemon
```

## 実行

`config.toml`は使わず引数ですべて指定する。  
`--cookie`は、未設定なら`~/.bitcoin/.cookie`から読むが、そうでなければ`"<rpcuser>:<rpcpassword>"`を設定する。
なので`rpcauth`でなくても使えるのかもしれないが確認はしていない。

`--electrum-rpc-addr`はElectrum APIのアドレス、`--http-addr`はEsplora APIのアドレスである。

`--cors`の設定は必要に応じて変更する。  
ここでは[esplora](./esplora.md)から呼び出される

```console
$ electrs --db-dir="/mnt/usb/electrs-data" \
    --network="regtest" \
    --cookie="testuser:testpass"  \
    --electrum-rpc-addr="localhost:50001" \
    --http-addr="localhost:3002" \
    --cors="http://localhost:5000"
```

スクリプトにしておくと楽か。

```script
#!/bin/bash

DATADIR="$HOME/.bitcoin/regtest/electrs"
NETWORK="regtest"
RPCUSER="testuser"
RPCPASS="testpass"
ZMQ_ADDR="localhost:28332"
ELECTRUM_URL="localhost:50001"
REST_URL="0.0.0.0:3002"
ESPLORA_URL="*"

electrs --db-dir="$DATADIR" \
    --network="$NETWORK" \
    --cookie="${RPCUSER}:${RPCPASS}"  \
    --zmq-addr="$ZMQ_ADDR" \
    --electrum-rpc-addr="$ELECTRUM_URL" \
    --http-addr="$REST_URL" \
    --cors="$ESPLORA_URL"
```

なお `ZMQ_ADDR` を指定しない場合は bitcoind を5秒感覚でポーリングする([ハードコーディング](https://github.com/Blockstream/electrs/blob/477c1a33eb29d7804d5f36baa1e14e768f9b6ff1/src/bin/electrs.rs#L138))。

### Electrum API

[Electrum Protocol](https://electrumx.readthedocs.io/en/latest/protocol.html)が使用できるようになっていればOK。

```console
$ echo '{"jsonrpc": "2.0", "method": "server.version", "params": ["", "1.4"], "id": 0}' | netcat localhost 50001
{"id":0,"jsonrpc":"2.0","result":["electrs-esplora 0.4.1","1.4"]}
```

### blockchain.transaction.getのverbose

[blockchain.transaction.get](https://electrum-protocol.readthedocs.io/en/latest/protocol-methods.html#blockchain-transaction-get)の第2引数 `verbose` 自体は受け付けるのだが
`true` はサポートされていないので指定してもエラーになる("verbose transactions are currently unsupported")。

## リンク

* [romanz/electrs](./electrs.md)
* [mempool/electrs](./electrs-ms.md)
