---
layout: "record"
title: "romanz/electrs"
tags:
  - bitcoin
  - tools
daily: false
create: "2025/04/07"
date: "2026/05/19"
---

## サイト

* [repository: github.com/romanz/electrs](https://github.com/romanz/electrs)

_確認日=2026/05/18_: v0.11.1

## 用途

Electrum Server の Rust 実装の 1つ。  
[Electrum Protocol](https://electrumx.readthedocs.io/en/latest/protocol.html) v1.4 をサポートしている。

派生に [Blockstream/electrs](https://github.com/Blockstream/electrs) や Blockstream版からの派生と思われる [mempool/electrs](https://github.com/mempool/electrs) などがある。  
Blockstream 版は [REST API](https://github.com/Blockstream/electrs?tab=readme-ov-file#notable-changes-from-electrs) もあるし、
ブロックエクスプローラの [Blockstream/esplora](https://github.com/Blockstream/esplora) には [Esplora REST API](https://github.com/Blockstream/esplora/blob/master/API.md) もある。

romanz/electrs は一般に公開するよりも個人で使うことを想定している。

## インストール

* [electrs/doc/install.md at v0.11.1 · romanz/electrs](https://github.com/romanz/electrs/blob/v0.11.1/doc/install.md)

librocksdb を static link するか dynamic link するか。  
ビルドする手間がいらないようだったので dynamic link にした。

* [Dynamic linking](https://github.com/romanz/electrs/blob/v0.11.1/doc/install.md#dynamic-linking)

## 実行

TOMLファイルでの項目名はアンダーバーだが実行ファイルの引数に与える場合はハイフンなので注意すること。  
(例: `cookie_file` ==> `--cookie-file`)

### config.toml

electrs の設定は `config.toml` という名前である。  
[テンプレート](https://github.com/romanz/electrs/blob/v0.11.1/doc/config_example.toml) を参考にすると良い。  
`cookie_file` と `db_dir` は変更するだろう。  
"highly recommended" ではあるが必須ではないそうだ。  
なお`cookie_file`は`bitcoin.conf`で[rpcauth](https://blog.hirokuma.work/bitcoin/01_basics/regtest.html#rpcauth)を設定しないと作られないので注意すること。
`config.toml`には`auth=<USER:PASSWORD>`の設定も使え、その場合はcookieがなくてもよい。

私の環境だとおおよそこんな感じである。  
Raspberry Pi 4 の IP アドレスが 192.168.0.30 なので `electrum_rpc_addr` で設定することで少なくとも LAN の中では公開という形にしている。

```toml
cookie_file = "/home/xxx/usbdisk/bitcoin/data/.cookie"
daemon_rpc_addr = "127.0.0.1:8332"
daemon_p2p_addr = "127.0.0.1:8333"
daemon_dir = "/home/xxx/usbdisk/bitcoin/data"
db_dir = "/home/xxx/hdddisk/electrs/db"
network = "bitcoin"
electrum_rpc_addr = "192.168.0.30:50001"
log_filters = "INFO"
```

ローカルのregtestではこういう設定を使った。

```toml
auth = "admin:admin"
daemon_rpc_addr = "127.0.0.1:18443"
daemon_p2p_addr = "127.0.0.1:18444"
db_dir = "./datadata"
network = "regtest"
electrum_rpc_addr = "127.0.0.1:50001"
```

### bitcoind

* [Bitcoind configuration](https://github.com/romanz/electrs/blob/v0.11.1/doc/config.md#bitcoind-configuration)

`cookie-file` を使う場合は `rpcauth` を設定して cookie ファイルが作られるようにしておく。  
[rpcauth.py](https://github.com/bitcoin/bitcoin/tree/master/share/rpcauth) は bitcoind が動いていなくても実行できるので、これで設定値を取得し、bitcoin.conf に追加して再起動すると datadir に `.cookie` ができている。  
そのフルパスを `config.toml` の `cookie_file` に書いておく。

`txindex=1` の設定は必須ではない。

### electrs実行

`config.toml` の検索は `/etc/electrs/config.toml`, `~/.electrs/config.toml`, `./config.toml` の順番になっている。
が、ローカルディレクトリに置いた`config.toml`はうまく読んでくれないかもしれない。`--conf <CONF_FILE>`で指定すると良い。

```bash
./electrs
```

実行すると bitcoind との同期が始まる。  
同期にかかった時間は計測していないが、`bitcoin-cli getblockchaininfo` の `"size_on_disk"` が `740028923219`(690GBくらい) で 50 GB 程度になった。

```shell
$ du -h
50G     ./db/bitcoin
50G     ./db
50G     .
```

ポートの LISTEN は最初から行われているようだ。  
いつから API にアクセスできるのかは未確認。

### systemd

systemd に登録する場合はこちらを参考にすると良い。  
`WorkingDirectory` を `config.toml` があるのと同じディレクトリにしたのだが、どうも読み取られないように見える。  
なので`--conf`ではなくパラメータを展開する。

* [Sample Systemd Unit File](https://github.com/romanz/electrs/blob/v0.11.1/doc/config.md#sample-systemd-unit-file)

```ini
.........
WorkingDirectory=/home/xxx/hdddisk/electrs
ExecStart=/home/xxx/hdddisk/electrs/electrs \
        --log-filters INFO \
        --network="bitcoin" \
        --db-dir="/home/xxx/hdddisk/electrs/db" \
        --daemon-dir="/home/xxx/usbdisk/bitcoin/data" \
        --cookie-file="/home/xxx/usbdisk/bitcoin/data/.cookie" \
        --electrum-rpc-addr="0.0.0.0:50001" \
        --daemon-p2p-addr="127.0.0.1:8333" \
        --daemon-rpc-addr="127.0.0.1:8332"
.........
```

## リンク

* [Blockstream/electrs](./electrs-bs.md)
* [mempool/electrs](./electrs-ms.md)
* 開発日記
  * [btc: ElectrumX API - hiro99ma blog](https://blog.hirokuma.work/2025/03/20250317-btc.html)
  * [btc: electrsのストレージは500GB超→ではない！ - hiro99ma blog](https://blog.hirokuma.work/2025/04/20250407-btc.html)
