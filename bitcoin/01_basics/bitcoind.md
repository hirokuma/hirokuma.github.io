# Bitcoin Core(bitcoind) を regtest で動かす

_最終更新日: 2025/02/19_

## はじめに

よほど野心的でない限り Bitcoin のフルノードを自作しようとは思わないだろう。  
ここでは最も一般的と思われる Bitcoin Core(bitcoind) のビルドとオプションについてメモを残す。  
Ubuntu 22.04 (WSL2) で確認しているが、既にいろいろインストールされているのでビルドに不足しているツールがあるかもしれない。

現時点で Bitcoin Core の最新バージョンは v28.1 のためそれを使っていく。  
以前のバージョン表記は `v0.XX.YY`(v0.21.2まで) だったが、比較的最近から `vXX.YY`(v22.0～) に変わった。
もし「v0.」で始まっている記事があっても、それがものすごく古いとは限らないことは覚えておいて良いだろう。
ただ記事の更新日時が新しいのに「v0.」の場合は単に日付だけ新しいだけなので気をつけよう。  
基本的に、周辺アプリの互換性の都合以外で Bitcoin Core の古いバージョンを使う必要はほぼない。

## リポジトリ

* [bitcoin/bitcoin at v28.1](https://github.com/bitcoin/bitcoin/tree/v28.1)

## ビルド

### 前準備

* [Linux Distribution Specific Instructions - v28.1](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#linux-distribution-specific-instructions)

```console
$ sudo apt-get install \
  build-essential \
  libtool \
  autotools-dev \
  automake \
  pkg-config \
  bsdmainutils \
  python3 \
  libevent-dev \
  libboost-dev \
  libsqlite3-dev
```

[ZMQ](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/zmq.md) を使うなら `libzmq3-dev` もいるだろう。
私の環境ではインストールしていない状態でビルドしたところ、`zmqpubrawblock` を設定してもエラーにならずにポートが開いていなかったので無視されたようだ。

DB をどうするか悩むかもしれない。  
新規環境だったりウォレットが無いのであればそのままにして、既に使っているウォレットがあるなら [Berkeley DB](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#berkeley-db) を使うとよいだろう。
`mainnet` では内蔵のウォレットを使わない方がよいだろう。

### Clone and Build

適当な場所に clone してリリースタグを checkout する。  
`master` を使いたいかもしれないので、その辺りは自身の判断で。

```console
$ git clone https://github.com/bitcoin/bitcoin.git
$ cd bitcoin
$ git checkout -b v28_1 refs/tags/v28.1
```

ビルドは `configure` のオプションを指定して `make` する。  
オプションはいろいろあるので `configure --help` で確認すると良い。
GUI無しで `$HOME/.local` にインストールするならこういう感じだ。

* [bitcoin/doc/build-unix.md at v28.1 · bitcoin/bitcoin](https://github.com/bitcoin/bitcoin/blob/v28.1/doc/build-unix.md#to-build)

```console
./autogen.sh
./configure --prefix=$HOME/.local --without-gui
make
make install
```
## 設定と実行

ノードとして動作する `bitcoind` や 操作する `bitcoin-cli` は設定ファイル `bitcoin.conf` を参照する。  
設定ファイルを使わず引数にしても同じことができるので、その辺りは自身の判断で。

regtest でしか使わないならこんな感じでよいだろう。

```conf
server=1
txindex=1
regtest=1
rpcbind=
rpcuser=ほげほげ
rpcpassword=ふがふが
fallbackfee=0.00001000
```

`rpcuser` と `rpcpassword` は JSON-RPC で通信したい場合に設定する。
代わりに [rpcauth](https://github.com/bitcoin/bitcoin/tree/v28.1/share/rpcauth) を使うこともできる。
`rpcauth` は複数設定することができる。

```console
$ ./share/rpcauth/rpcauth.py user pass
String to be appended to bitcoin.conf:
rpcauth=user:<省略>
Your password:
pass

$ ./share/rpcauth/rpcauth.py user2 pass2
String to be appended to bitcoin.conf:
rpcauth=user2:<省略>
Your password:
pass2
```

出力された `rpcauth` の行を `bitcoin.conf` にそれぞれ貼り付けて `bitcoind` を起動する。

```console
$ curl --user user:pass --data-binary '{"jsonrpc": "2.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: application/json' http://127.0.0.1:18443/
{"jsonrpc":"2.0","result":0,"id":"curltest"}

$ curl --user user2:pass2 --data-binary '{"jsonrpc": "2.0", "id": "curltest", "method": "getblockcount", "params": []}' -H 'content-type: application/json' http://127.0.0.1:18443/
{"jsonrpc":"2.0","result":0,"id":"curltest"}
```

### ポート番号

bitcoind がデフォルトで使用するポート番号を以下に示す。  
ZMQ はポート番号指定が必要なので記載していない。

| network | P2P | P2P(onion) | RPC |
| -- | -- | -- | -- |
| mainnet | 8333 | 8334 | 8332 |
| testnet3 | 18333 | 18334 | 18332 |
| testnet4 | 48333 | 48334 | 48332 |
| signet | 38333 | 38334 | 38332 |
| regtest | 18444 | 18445 | 18443 |

ZMQ はデフォルトのポート番号はない。

## ウォレットの作成

デフォルトでは `bitcoind` を立ち上げてもウォレットが存在しない。  
regtest の場合はブロック生成した報酬を使ってテストをするので、ウォレットを作るのが楽である。

```console
$ bitcoin-cli createwallet ""
{
  "name": ""
}
```

ウォレットに受け取り用アドレスを作ってブロック生成する。

```console
$ addr=`bitcoin-cli -regtest getnewaddress`
$ bitcoin-cli -regtest generatetoaddress 150 $addr
$ bitcoin-cli -regtest getbalance
```

## おわりに

regtest で `bitcoind` を立ち上げる手順を説明した。

## 関連ページ

* [インストール](./install.md)
* [ウォレット](./wallet.md)
* [ブロック](/.blocks.md)
* [トランザクション](./transactions.md)
* [アドレス](./address.md)
* [スクリプト](./script.md)
