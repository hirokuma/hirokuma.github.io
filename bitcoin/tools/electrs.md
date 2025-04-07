# tools: romanz/electrs

[repository](https://github.com/romanz/electrs)

_2025/04/07_: v0.10.9

## 用途

Electrum Server の Rust 実装。  
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

実行すると bitcoind との同期が始まる。  
500 GB 超のストレージが必要になる。

(同期中。。。)
