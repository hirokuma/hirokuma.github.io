---
layout: "record"
title: "mempool.space/electrs"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/08/03"
---

## サイト

* [repository: github.com/mempool/electrs](https://github.com/mempool/electrs)

オリジナルは[romanz/electrs](./electrs.md)だが、作りとしては[Blockstream/electrs](./electrs-bs.md)がベースだろう。  
REST API に追加があるので、こちらでないと動かないアプリがあるかもしれない。

## インストール

* [Installing & indexing](https://github.com/mempool/electrs?tab=readme-ov-file#installing--indexing)

```console
$ git clone https://github.com/mempool/electrs && cd electrs
$ cargo build --release --bin electrs
...(略)...
$ ls -l target/release/electrs
-rwxr-xr-x 2 xxxx xxxx 13593504 Aug  3 09:34 target/release/electrs
```

### help

```console
$ ./target/release/electrs --help
Mempool Electrum Rust Server 3.3.0-dev

USAGE:
    electrs [FLAGS] [OPTIONS]

FLAGS:
        --address-search        Enable prefix address search
    -h, --help                  Prints help information
        --index-unspendables    Enable indexing of provably unspendable outputs
        --jsonrpc-import        Use JSONRPC instead of directly importing blk*.dat files. Useful for remote full node or
                                low memory system
        --lightmode             Enable light mode for reduced storage
        --timestamp             Prepend log lines with a timestamp
    -v                          Increase logging verbosity
        --version               Print out the version of this app and quit immediately.

OPTIONS:
        --blocks-dir <blocks_dir>
            Analogous to bitcoind's -blocksdir option, this specifies the directory containing the raw blocks files
            (blk*.dat) (default: ~/.bitcoin/blocks/)
        --cookie <cookie>
            JSONRPC authentication cookie ('USER:PASSWORD', default: read from ~/.bitcoin/.cookie)

        --cors <cors>
            Origins allowed to make cross-site requests

        --daemon-dir <daemon_dir>
            Data directory of Bitcoind (default: ~/.bitcoin/)

        --daemon-rpc-addr <daemon_rpc_addr>
            Bitcoin daemon JSONRPC 'addr:port' to connect (default: 127.0.0.1:8332 for mainnet, 127.0.0.1:18332 for
            testnet and 127.0.0.1:18443 for regtest)
        --db-dir <db_dir>
            Directory to store index database (default: ./db/)

        --electrum-banner <electrum_banner>
            Welcome banner for the Electrum server, shown in the console to clients.

        --electrum-rpc-addr <electrum_rpc_addr>
            Electrum server JSONRPC 'addr:port' to listen on (default: '127.0.0.1:50001' for mainnet, '127.0.0.1:60001'
            for testnet and '127.0.0.1:60401' for regtest)
        --electrum-txs-limit <electrum_txs_limit>
            Maximum number of transactions returned by Electrum history queries. Lookups with more results will fail.
            [default: 500]
        --http-addr <http_addr>
            HTTP server 'addr:port' to listen on (default: '127.0.0.1:3000' for mainnet, '127.0.0.1:3001' for testnet
            and '127.0.0.1:3002' for regtest)
        --http-socket-file <http_socket_file>
            HTTP server 'unix socket file' to listen on (default disabled, enabling this disables the http server)

        --magic <magic>                                                                   [default: ]
        --main-loop-delay <main_loop_delay>
            The number of milliseconds the main loop will wait between loops. (Can be shortened with SIGUSR1) [default:
            500]
        --mempool-backlog-stats-ttl <mempool_backlog_stats_ttl>
            The number of seconds that need to pass before Mempool::update will update the latency histogram again.
            [default: 10]
        --mempool-recent-txs-size <mempool_recent_txs_size>
            The number of transactions that mempool will keep in its recents queue. This is returned by mempool/recent
            endpoint. [default: 10]
        --monitoring-addr <monitoring_addr>
            Prometheus monitoring 'addr:port' to listen on (default: 127.0.0.1:4224 for mainnet, 127.0.0.1:14224 for
            testnet and 127.0.0.1:24224 for regtest)
        --network <network>
            Select network type (mainnet, testnet, regtest, signet)

        --precache-scripts <precache_scripts>
            Path to file with list of scripts to pre-cache

        --precache-threads <precache_threads>
            Non-zero number of threads to use for precache threadpool. [default: 4 * CORE_COUNT]

        --rest-default-block-limit <rest_default_block_limit>
            The default number of blocks returned from the blocks/[start_height] endpoint. [default: 10]

        --rest-default-chain-txs-per-page <rest_default_chain_txs_per_page>
            The default number of on-chain transactions returned by the txs endpoints. [default: 25]

        --rest-default-max-address-summary-txs <rest_default_max_address_summary_txs>
            The default number of transactions returned by the address summary endpoints. [default: 5000]

        --rest-default-max-mempool-txs <rest_default_max_mempool_txs>
            The default number of mempool transactions returned by the txs endpoints. [default: 50]

        --rest-max-mempool-page-size <rest_max_mempool_page_size>
            The maximum number of transactions returned by the paginated /internal/mempool/txs endpoint. [default: 1000]

        --rest-max-mempool-txid-page-size <rest_max_mempool_txid_page_size>
            The maximum number of transactions returned by the paginated /mempool/txids/page endpoint. [default: 10000]

        --rpc-socket-file <rpc_socket_file>
            Electrum RPC 'unix socket file' to listen on (default disabled, enabling this ignores the electrum_rpc_addr
            arg)
        --utxos-limit <utxos_limit>
            Maximum number of utxos to process per address. Lookups for addresses with more utxos will fail. Applies to
            the Electrum and HTTP APIs. [default: 500]
```

## おわりに

regtestでトランザクションの前後移動をしたくて[mempool/mempool](https://github.com/mempool/mempool)を導入しようかと思ってビルドしたのだが、
mempool/mempoolの構築が面倒そうだったので止めたため、これ以上は使っていない。
