---
title: "romanz/electrs"
tags:
  - bitcoin
  - tools
daily: false
date: "2025/04/07"
---

[repository](https://github.com/romanz/electrs)

_2025/04/07_: v0.10.9

## 用途

Electrum Server の Rust 実装の 1つ。  
[Electrum Protocol](https://electrumx.readthedocs.io/en/latest/protocol.html) v1.4 をサポートしている。

派生に [Blockstream/electrs](https://github.com/Blockstream/electrs) や Blockstream版からの派生と思われる [mempool/electrs](https://github.com/mempool/electrs) などがある。  
Blockstream 版は [REST API](https://github.com/Blockstream/electrs?tab=readme-ov-file#notable-changes-from-electrs) もあるし、
ブロックエクスプローラの [Blockstream/esplora](https://github.com/Blockstream/esplora) には [Esplora REST API](https://github.com/Blockstream/esplora/blob/master/API.md) もある。

romanz/electrs は一般に公開するよりも個人で使うことを想定している。

## インストール

* [electrs/doc/install.md at v0.10.9 · romanz/electrs](https://github.com/romanz/electrs/blob/v0.10.9/doc/install.md)

librocksdb を static link するか dynamic link するか。  
ビルドする手間がいらないようだったので dynamic link にした。
dynamic link するとアップデートが簡単、みたいに書いてあるけど v7.8.3 とバージョン指定してるならアップデートしてよいんだろうか？ 
この辺は apt のしくみをよく知らないのだ。  
少なくとも v7.8.4 と v7.9.0 はなかったので v7 系では最新っぽい。

* [Dynamic linking](https://github.com/romanz/electrs/blob/v0.10.9/doc/install.md#dynamic-linking)

## 実行

### config.toml

electrs の設定は `config.toml` という名前である。  
[テンプレート](https://github.com/romanz/electrs/blob/v0.10.9/doc/config_example.toml) を参考にすると良い。  
`cookie_file` と `db_dir` は変更するのではないかな。

`config_specification.toml` が設定できるパラメータ名で `Config` が最終的に使われる設定値なのかな。

* [internal/config_specification.toml](https://github.com/romanz/electrs/blob/v0.10.9/internal/config_specification.toml)
* [Config](https://github.com/romanz/electrs/blob/v0.10.9/src/config.rs#L125-L148)

```rust
pub struct Config {
    // See below for the documentation of each field:
    pub network: Network,
    pub db_path: PathBuf,
    pub db_log_dir: Option<PathBuf>,
    pub db_parallelism: u8,
    pub daemon_auth: SensitiveAuth,
    pub daemon_rpc_addr: SocketAddr,
    pub daemon_p2p_addr: SocketAddr,
    pub electrum_rpc_addr: SocketAddr,
    pub monitoring_addr: SocketAddr,
    pub wait_duration: Duration,
    pub jsonrpc_timeout: Duration,
    pub index_batch_size: usize,
    pub index_lookup_limit: Option<usize>,
    pub reindex_last_blocks: usize,
    pub auto_reindex: bool,
    pub ignore_mempool: bool,
    pub sync_once: bool,
    pub skip_block_download_wait: bool,
    pub disable_electrum_rpc: bool,
    pub server_banner: String,
    pub signet_magic: Magic,
}
```

私の環境だとおおよそこんな感じである。  
Raspberry Pi 4 の IP アドレスが 192.168.0.30 なので `electrum_rpc_addr` で設定することで少なくとも LAN の中では公開という形にしている(よね？)。

```conf
cookie_file = "/home/xxx/usbdisk/bitcoin/data/.cookie"
daemon_rpc_addr = "127.0.0.1:8332"
daemon_p2p_addr = "127.0.0.1:8333"
daemon_dir = "/home/xxx/usbdisk/bitcoin/data"
db_dir = "/home/xxx/hdddisk/electrs/db"
network = "bitcoin"
electrum_rpc_addr = "192.168.0.30:50001"
log_filters = "INFO"
```

### bitcoind

`rpcauth` を設定して cookie ファイルが作られるようにしておく。  
[rpcauth.py](https://github.com/bitcoin/bitcoin/tree/master/share/rpcauth) は bitcoind が動いていなくても実行できるので、これで設定値を取得し、bitcoin.conf に追加して再起動すると datadir に `.cookie` ができている。  
そのフルパスを `config.toml` の `cookie_file` に書いておく。

### 実行

`config.toml` の検索は `/etc/electrs/config.toml`, `~/.electrs/config.toml`, `./config.toml` の順番になっている。

```bash
export RUST_LOG=${RUST_LOG-electrs=INFO}
./electrs --daemon-dir $HOME/.bitcoin
```

systemd に登録する場合はこちらを参考にすると良い。  
`WorkingDirectory` を `config.toml` があるのと同じディレクトリにしたのだが、どうも読み取られないように見える。  
`--conf` で指定するのが安全そうだ。

* [Sample Systemd Unit File](https://github.com/romanz/electrs/blob/v0.10.9/doc/config.md#sample-systemd-unit-file)

```ini
.........
WorkingDirectory=/home/xxx/hdddisk/electrs
ExecStart=/home/xxx/hdddisk/electrs/electrs --conf="/home/xxx/hdddisk/electrs/config.toml"
.........
```

実行すると bitcoind との同期が始まる。  
同期にかかった時間は計測していないが、`bitcoin-cli getblockchaininfo` の `"size_on_disk"` が `740028923219`(690GBくらい) で 50 GB 程度になった。

```console
$ du -h
50G     ./db/bitcoin
50G     ./db
50G     .
```

ポートの LISTEN は最初から行われているようだ。  
いつから API にアクセスできるのかは未確認。

```console
$ echo '{"jsonrpc": "2.0", "method": "server.version", "params": ["", "1.4"], "id": 0}' | netcat 192.168.0.30 50001
{"id":0,"jsonrpc":"2.0","result":["electrs/0.10.9","1.4"]}
^C
```

ブロックチェーンのデータにアクセスできることも見ておく。  
[blockchain.block.header](https://electrumx.readthedocs.io/en/latest/protocol-methods.html#blockchain-block-header) はこう。  
`cp_height` を付けるとエラーになるが[electrumがそうだから](https://github.com/romanz/electrs/issues/1080)だそうだ。

```console
 $ echo '{"jsonrpc": "2.0", "method": "blockchain.block.header", "params": [5], "id": 0}' | netcat 192.168.0.30 50001
{"id":0,"jsonrpc":"2.0","result":"0100000085144a84488ea88d221c8bd6c059da090e88f8a2c99690ee55dbba4e00000000e11c48fecdd9e72510ca84f023370c9a38bf91ac5cae88019bee94d24528526344c36649ffff001d1d03e477"}
```

`bitcoin-cli` で確認するとデータは一致している。

```console
$ bitcoin-cli getblockhash 5
000000009b7262315dbf071787ad3656097b892abffd1f95a1a022f896f533fc
$ bitcoin-cli getblockheader 000000009b7262315dbf071787ad3656097b892abffd1f95a1a022f896f533fc false
0100000085144a84488ea88d221c8bd6c059da090e88f8a2c99690ee55dbba4e00000000e11c48fecdd9e72510ca84f023370c9a38bf91ac5cae88019bee94d24528526344c36649ffff001d1d03e477
```
