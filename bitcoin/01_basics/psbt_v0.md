---
layout: record
title: "PSBT v0"
tags:
  - bitcoin
daily: false
date: "2025/10/27"
---

## はじめに

"Partially Signed Bitcoin Transaction"の略。

ときどき、署名だけを他の人にやってもらいたいという状況がある。
MultiSig のようなこともあれば、鍵を持たせないアプリでトランザクションだけ作って署名はウォレットで行う、ということもあるだろう。

PSBT はそういったときに使用できるデータフォーマットである。  
これがないときは各アプリでフォーマットを決めていたので共通性がなかった。

現在(2025/08/19)のところ version 0([BIP-174](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki)、以下 PSBTv0) と version 2([BIP-370](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki)、以下 PSBTv2) の 2つがある。version 1 はない。

詳細は各人で確認するのが良い。自分でデータを作るよりもツールやAPIなどでやった方がよいだろう。  
たとえば C言語系なら [libwally-core/psbt](https://wally.readthedocs.io/en/latest/psbt.html) が使えるだろう(Pythonのラッパーもあると思う)。
スクロールバーを見ると分かるが、非常に項目が多い。  
[bitcoinjs-lib](https://github.com/bitcoinjs/bitcoinjs-lib)はトランザクションを作るときはだいたい PSBT 関連の構造体を使っていたように思う。

などなど、API で見てしまうと切りがない。  
ここでは私が気になったところだけにする。

## PSBTv0 と PSBTv2 の違い

[BIP-370](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki#abstract)に

> which allows for inputs and outputs to be added to the PSBT after creation.

と書かれているので、後からでも INPUT/OUTPUT を追加できるようにしたのが PSBTv2 と思われる。  
ただしフォーマットに互換性はないとのこと。

今のところ(2025/08/21)、PSBTv2 に対応しているアプリやサービスは少ない。  
Bitcoin Core もまだ対応していないので、主に PSBTv0 を見ていく。

## 概要

"psbt" ヘッダで始まる key-value 式のバイナリデータである。  
大きく `<global-map>`、`<input-map>`、`<output-map>` の 3つに分かれる。  
それぞれセパレータとして `0x00` を終わりに置く。
`<input-map>` と `<output-map>` は複数置くことができる。

* [Structure - Partially Signed Bitcoin Transaction](https://learnmeabitcoin.com/technical/transaction/psbt/#structure)

![image](images/psbt-1.png)

## Roles

"partially" といっているように、ちょっとずつデータを埋めながら完成させていくことができる。
そうすると、今どこまでできあがっていて何ができるのかが分かりづらい。  
役割(role)によって何ができるのかを決めているもので、PSBT データの役割というよりは、
その PSBT データに我々は何ができるかというような考え方になるようだ。

[Roles](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#user-content-Roles)

* Creator
  * 新しい空の PSBT を作る
  * これ以外の role では何らかの PSBT に対しての操作を行う
* Updater
  * PSBT に情報の追加を行う
* Signer
  * PSBT に署名を行う
  * UTXO の確認のような署名できるかどうかのチェックも行う
* Combiner
  * 1つ以上の PSBT を受け取って 1つの PSBT にマージする
* Input Finalizer
* Transaction Extractor

Bitcoin Core では `analyzepsbt` で確認できる。

## bitcoin-cli

v29.0 で "psbt" をコマンド名に含むものを洗い出した。

今のところ bitcoind は PSBTv2 をサポートしていないそうだ([Implement BIP 370 PSBTv2 by achow101 · Pull Request #21283 · bitcoin/bitcoin · GitHub](https://github.com/bitcoin/bitcoin/pull/21283))。

### 実行例1

regtest でウォレットを持っている状態で PSBT を使ってトランザクション展開まで行う。  
どちらも自分のウォレット宛だが、送金先とお釣りのイメージで output を指定している。  
bitcoin-cli では手数料率を指定できる PSBT 関連のコマンドが `walletcreatefundedpsbt` だけらしい(まだ使ったことが無い)。
`createpsbt` など手数料率を指定できないオプションを使う場合はお釣りの output も指定しないと input の総額から output の総額を引いた額がすべて手数料になるよう計算される。

そう書くと不親切に見えるが、単純に指定したデータを使ってトランザクションを構築しているだけである。
トランザクションの展開は別のコマンドで行うので、それまでに `decoderawtransaction` などで確認を忘れないようにすること。

```shell
$ bitcoin-cli listunspent
....

# listunspentの結果から"txid"と"vout"を選ぶ
$ TXIN="...."
$ VOUT=...

# 送金先アドレス
$ ADDR=`bitcoin-cli getnewaddress`
$ ADDR2=`bitcoin-cli getnewaddress`

$ PSBT=`bitcoin-cli createpsbt '[{"txid":"'$TXIN'","vout":'$VOUT'}]' '[{"'$ADDR'":0.00001}, {"'$ADDR2'":49.998}]'`
$ bitcoin-cli analyzepsbt $PSBT
{
  "inputs": [
    {
      "has_utxo": false,
      "is_final": false,
      "next": "updater"
    }
  ],
  "next": "updater"
}

$ PSBT2=`bitcoin-cli utxoupdatepsbt $PSBT`
$ bitcoin-cli analyzepsbt $PSBT2
{
  "inputs": [
    {
      "has_utxo": true,
      "is_final": false,
      "next": "updater"
    }
  ],
  "estimated_vsize": 130,
  "estimated_feerate": 0.00760269,
  "fee": 0.00098835,
  "next": "updater"
}

$ PROC=`bitcoin-cli walletprocesspsbt $PSBT2`
$ echo $PROC | jq .complete
true
$ bitcoin-cli analyzepsbt `echo $PROC | jq -r .psbt`
{
  "inputs": [
    {
      "has_utxo": true,
      "is_final": true,
      "next": "extractor"
    }
  ],
  "fee": 0.00098835,
  "next": "extractor"
}

$ bitcoin-cli sendrawtransaction `echo $PROC | jq -r .hex`
9a959aeef2f6c1c5e1383a0fbfa3fe5eac182b41ebbb2cca0587df2c01988ffd
```

### 実行例2

実行例1 で output にお釣りを指定しなかった場合。  
fee が大きすぎるトランザクションになってしまうが、作成自体は成功する。  
トランザクションを展開する際、fee の上限を超えたため展開には失敗する。

input の額によっては展開に成功してしまうということでもあるので、展開前の確認を必ず行おう。

```shell
$ bitcoin-cli listunspent
....

# listunspentの結果から"txid"と"vout"を選ぶ
$ TXIN="...."
$ VOUT=...

# 送金先アドレス
$ ADDR=`bitcoin-cli getnewaddress`

$ PSBT=`bitcoin-cli createpsbt '[{"txid":"'$TXIN'","vout":'$VOUT'}]' '[{"'$ADDR'":0.00001}]'`
$ bitcoin-cli analyzepsbt $PSBT
{
  "inputs": [
    {
      "has_utxo": false,
      "is_final": false,
      "next": "updater"
    }
  ],
  "next": "updater"
}

$ PSBT2=`bitcoin-cli utxoupdatepsbt $PSBT`
$ bitcoin-cli analyzepsbt $PSBT2
{
  "inputs": [
    {
      "has_utxo": true,
      "is_final": false,
      "next": "updater",
      "missing": {
        "pubkeys": [
          "b4abcd7ffce2c069bbfa2ff3f0ed24c068bd09bd"
        ]
      }
    }
  ],
  "fee": 49.99999000,
  "next": "updater"
}

$ PROC=`bitcoin-cli walletprocesspsbt $PSBT2`
$ echo $PROC | jq .complete
true
$ bitcoin-cli analyzepsbt `echo $PROC | jq -r .psbt`
{
  "inputs": [
    {
      "has_utxo": true,
      "is_final": true,
      "next": "extractor"
    }
  ],
  "estimated_vsize": 110,
  "estimated_feerate": 454.54536363,
  "fee": 49.99999000,
  "next": "extractor"
}
$ bitcoin-cli sendrawtransaction `echo $PROC | jq -r .hex`
error code: -25
error message:
Fee exceeds maximum configured by user (e.g. -maxtxfee, maxfeerate)
```

### 各コマンド

#### [analyzepsbt](https://developer.bitcoin.org/reference/rpc/analyzepsbt.html)

与えた PSBTv0 base64 文字列を簡易的に調べて現在の状態を教えてくれる。  
"next" はおそらく [Roles](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#user-content-Roles)。  
[ソースコード](https://github.com/bitcoin/bitcoin/blob/v29.0/src/psbt.cpp#L524-L534)からすると以下。

* creator
* updater
* signer
* finalizer
* extractor

input が未設定の場合は "extractor" になった。  
"must only accept a PSBT" と書いてあるが、これはいくつかの role にも書かれている。
Transaction Extractor では input の scriptSig や scriptWitness を確認するので、まだ input がない PSBT だと「次は Transaction Extractor だから input の設定が必要」という読み方をすれば良いか。

```shell
$ PSBT=`bitcoin-cli createpsbt '[]' '[{"bcrt1qh5kmd2rq23l9qwykn6dtdkfhtvt550ux5ffd0y":0.0001}]'`
$ bitcoin-cli analyzepsbt $PSBT
{
  "estimated_vsize": 41,
  "estimated_feerate": -0.00243902,
  "fee": -0.00010000,
  "next": "extractor"
}
```

"extractor" は `walletprocesspsbt` に与えると成功してしまう。  
しかし input は空なので署名などもなく、`sendrawtransaction` しても失敗する。

```shell
$ bitcoin-cli walletprocesspsbt $PSBT
{
  "psbt": "cHNidP8BACkCAAAAAAEQJwAAAAAAABYAFL0ttqhgVH5QOJaemrbZN1sXSj+GAAAAAAAA",
  "complete": true,
  "hex": "0200000000011027000000000000160014bd2db6a860547e5038969e9ab6d9375b174a3f8600000000"
}

$ bitcoin-cli sendrawtransaction 0200000000011027000000000000160014bd2db6a860547e5038969e9ab6d9375b174a3f8600000000
error code: -22
error message:
TX decode failed. Make sure the tx has at least one input.
```

`bitcoin-cli listunspent` の UTXO を input に追加した PSBT では ["updater"](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki#updater) になった。  
「次は input を追加するか、redeemScript か witnessScript などを追加すること」という意味だろう。  
`listunspent` で取得した outPoint なのに "has_utxo" が false となるのは、PSBT の中に input の UTXO情報がまだ入っていないためだ。

```shell
$ PSBT=`bitcoin-cli createpsbt '[{"txid":"1dcadd8c3096f1e7e127f10fe681c403f4782278c3225ae1820bf218cdfd4c58","vout":0}]' '[{"bcrt1qh5kmd2rq23l9qwykn6dtdkfhtvt550ux5ffd0y":0.0001}]'`
$ bitcoin-cli analyzepsbt $PSBT
{
  "inputs": [
    {
      "has_utxo": false,
      "is_final": false,
      "next": "updater"
    }
  ],
  "next": "updater"
}
```

`utxoupdatepsbt` で UTXO情報を更新すると "has_utxo" は true になった。

```shell
$ PSBT2=`bitcoin-cli utxoupdatepsbt $PSBT`
$ bitcoin-cli analyzepsbt $PSBT2
{
  "inputs": [
    {
      "has_utxo": true,
      "is_final": false,
      "next": "updater",
      "missing": {
        "pubkeys": [
          "b2f1a744e1b2ba1d248ab91ab126579641d08c00"
        ]
      }
    }
  ],
  "fee": 49.99990000,
  "next": "updater"
}
```

input transaction の outPoint はこうなっていた。
この "scriptPubKey.asm" の witness program と outPoint の "missing.pubkeys" が一致しているのが確認できる。

```json
    {
      "value": 50.00000000,
      "n": 0,
      "scriptPubKey": {
        "asm": "0 b2f1a744e1b2ba1d248ab91ab126579641d08c00",
        "desc": "addr(bcrt1qktc6w38pk2ap6fy2hydtzfjhjeqaprqqv7auy9)#ejg7wzpz",
        "hex": "0014b2f1a744e1b2ba1d248ab91ab126579641d08c00",
        "address": "bcrt1qktc6w38pk2ap6fy2hydtzfjhjeqaprqqv7auy9",
        "type": "witness_v0_keyhash"
      }
    },
```

データ構造でいえば、`$PSBT` は `<global_map>` の `PSBT_GLOBAL_UNSIGNED_TX`(未署名で input と output がある raw-tx) だけなのだが、
`$PSBT2` は `<input-map #0>` に `PSBT_IN_NON_WITNESS_UTXO`(input の raw-tx) と `PSBT_IN_WITNESS_UTXO`(outPoint の raw-data) が追加されていた。  
つまり、秘密鍵以外でトランザクションに署名するのに必要なデータを全部詰め込もうとしているのだ。

プログラムでトランザクションに署名しようとするとわかるのだが、いろいろなデータが必要になる。
特に segwit トランザクションは input になるトランザクションのデータも署名対象になるので面倒である。  
PSBT のデータを作るのも同じくらい手間がかかると思えば良いだろう。  
その代わりといってはなんだが、署名処理を実装するときは PSBT のデータを作るように進めていけば間違いはないだろう。

#### [combinepsbt](https://developer.bitcoin.org/reference/rpc/combinepsbt.html)

#### [converttopsbt](https://developer.bitcoin.org/reference/rpc/converttopsbt.html)

#### [createpsbt](https://developer.bitcoin.org/reference/rpc/createpsbt.html)

output は必須だが `walletcreatefundedpsbt` と違って input は省略できないが空にしておくことはできる。  
しかし `bitcoin-cli` には input/output を追加するコマンドはないらしい。
`decodepsbt` でデコードして作り直せば済むからだろうか。

```shell
$ bitcoin-cli createpsbt '[]' '[{"bcrt1qyz7yq6m6rdqxaypzrz0qywj40448926dxz60eg":0.0001}]'
cHNidP8BACkCAAAAAAEQJwAAAAAAABYAFCC8QGt6G0BukCIYngI6VX1qcqtNAAAAAAAA
```

input と output は配列で指定できる。  
特に output はお釣りの設定を忘れないようにしよう。
そうしないと上に載せた例のように fee が高すぎて展開できない、だったらまだよいとして、
意図せず高い手数料で展開してしまうということがあり得る。

```shell
$ bitcoin-cli createpsbt '[{"txid":"8514c2b50431b9a59be4ba5813a23f1559a6a43a1344950f1747f5d383dbd699","vout":0}]' '[{"bcrt1qyz7yq6m6rdqxaypzrz0qywj40448926dxz60eg":0.0001}]' 0 true
cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAAA

$ bitcoin-cli -named createpsbt inputs='[{"txid":"8514c2b50431b9a59be4ba5813a23f1559a6a43a1344950f1747f5d383dbd699","vout":0}]' outputs='[{"bcrt1qyz7yq6m6rdqxaypzrz0qywj40448926dxz60eg":0.0001}]' replaceable=true
cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAAA
```

これだけでは署名がないため `finalizepsbt` しても失敗("complete"=false)する。

```shell
$ bitcoin-cli finalizepsbt cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAAA
{
  "psbt": "cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAAA",
  "complete": false
}
```

input が bitcoind のウォレットだった場合、`walletprocesspsbt` で署名することができる。  
こちらは regtest での実行例。

```shell
$ bitcoin-cli walletprocesspsbt cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAAA
{
  "psbt": "cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAEAgwIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/////AlEA/////wIA8gUqAQAAABYAFKF4tU8/qXlx9NpgO2wsP4E4PwNbAAAAAAAAAAAmaiSqIant4vYcP3HR3v0/qZnfo2lTdVxpBol5mWK0i+vYNpdOjPkAAAAAAQEfAPIFKgEAAAAWABSheLVPP6l5cfTaYDtsLD+BOD8DWwEIawJHMEQCIAK6ZP4wGtznzftRc4xfDjWHkjri0XpjalfFJdtZsb81AiAqT1RkGfXFbkKkJAECE8eJYJX4V2aJrlXDV5zvV146MgEhA6NpGWa5VloKcla51LY18/XbmVrwCiz/gaj3iHdRgt08ACICA5M7j0nG3X9V3Gyo5qdUKsQZlRUrrcHx5URyRqfOL1H/GFZDv61UAACAAQAAgAAAAIAAAAAAAgAAAAA=",
  "complete": true,
  "hex": "0200000000010199d6db83d3f547170f9544133aa4a659153fa21358bae49ba5b93104b5c214850000000000fdffffff01102700000000000016001420bc406b7a1b406e9022189e023a557d6a72ab4d02473044022002ba64fe301adce7cdfb51738c5f0e3587923ae2d17a636a57c525db59b1bf3502202a4f546419f5c56e42a424010213c7896095f8576689ae55c3579cef575e3a32012103a3691966b9565a0a7256b9d4b635f3f5db995af00a2cff81a8f788775182dd3c00000000"
}
```

その結果を `finalizepsbt` に与えると成功する。
今回は HEXデータは `walletprocesspsbt` と同じなので特に finalize は必要なかった。

```shell
$ bitcoin-cli finalizepsbt "cHNidP8BAFICAAAAAZnW24PT9UcXD5VEEzqkplkVP6ITWLrkm6W5MQS1whSFAAAAAAD9////ARAnAAAAAAAAFgAUILxAa3obQG6QIhieAjpVfWpyq00AAAAAAAEAgwIAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/////AlEA/////wIA8gUqAQAAABYAFKF4tU8/qXlx9NpgO2wsP4E4PwNbAAAAAAAAAAAmaiSqIant4vYcP3HR3v0/qZnfo2lTdVxpBol5mWK0i+vYNpdOjPkAAAAAAQEfAPIFKgEAAAAWABSheLVPP6l5cfTaYDtsLD+BOD8DWwEIawJHMEQCIAK6ZP4wGtznzftRc4xfDjWHkjri0XpjalfFJdtZsb81AiAqT1RkGfXFbkKkJAECE8eJYJX4V2aJrlXDV5zvV146MgEhA6NpGWa5VloKcla51LY18/XbmVrwCiz/gaj3iHdRgt08ACICA5M7j0nG3X9V3Gyo5qdUKsQZlRUrrcHx5URyRqfOL1H/GFZDv61UAACAAQAAgAAAAIAAAAAAAgAAAAA="
{
  "hex": "0200000000010199d6db83d3f547170f9544133aa4a659153fa21358bae49ba5b93104b5c214850000000000fdffffff01102700000000000016001420bc406b7a1b406e9022189e023a557d6a72ab4d02473044022002ba64fe301adce7cdfb51738c5f0e3587923ae2d17a636a57c525db59b1bf3502202a4f546419f5c56e42a424010213c7896095f8576689ae55c3579cef575e3a32012103a3691966b9565a0a7256b9d4b635f3f5db995af00a2cff81a8f788775182dd3c00000000",
  "complete": true
}
```

#### [decodepsbt](https://developer.bitcoin.org/reference/rpc/decodepsbt.html)

`decodepsbt` はバイナリの PSBT構造を JSON フォーマットにして出力する。  
見やすいが、元の PSBT フォーマットと見比べるのは難しい。

#### [descriptorprocesspsbt](https://bitcoincore.org/en/doc/28.0.0/rpc/rawtransactions/descriptorprocesspsbt/)

#### [finalizepsbt](https://developer.bitcoin.org/reference/rpc/finalizepsbt.html)

全部の input に適切な処理がされていたら、`sendrawtransaction` でブロードキャストできる HEX文字列を出力する。  
PSBT 文字列の通りにしかトランザクションを作らないので、念のために `decoderawtransaction` などで内容を確認した方がよい。
特に fee が期待した値なのか確認した方がよい。お釣りの output がないため送金額以外が全部 fee になる、ということをやってしまうからだ。

#### [joinpsbts](https://developer.bitcoin.org/reference/rpc/joinpsbts.html)

#### [utxoupdatepsbt](https://developer.bitcoin.org/reference/rpc/utxoupdatepsbt.html)

input の UTXO 情報を更新する。  


### Wallets

#### [psbtbumpfee](https://developer.bitcoin.org/reference/rpc/psbtbumpfee.html)

#### [walletcreatefundedpsbt](https://developer.bitcoin.org/reference/rpc/walletcreatefundedpsbt.html)

#### [walletprocesspsbt](https://developer.bitcoin.org/reference/rpc/walletprocesspsbt.html)

## 使用例

### LND

LND では PSBT を使うことができる。  
チャネルを開きたいけど LND のウォレットに amount がない、というときに使ったように思う。
feerate が高いときだと LND に送るのですらためらうし、confirm がいつになるのかわからないので、支払えるウォレットを使うという選択肢を持っていて良いだろう。

* [Partially Signed Bitcoin Transactions - Builder's Guide](https://docs.lightning.engineering/lightning-network-tools/lnd/psbt)

`bumpfee` のときにも使ったような気がするが、忘れてしまった。

## 関連ページ

* [BIP174 - PSBT version 0](https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki)
* [BIP370 - PSBT version 2](https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki)
* [Partially signed bitcoin transactions - Bitcoin Optech](https://bitcoinops.org/en/topics/psbt/)
* [PSBT - Partially Signed Bitcoin Transaction](https://learnmeabitcoin.com/technical/transaction/psbt/)
* [doc/psbt.md - v29.0](https://github.com/bitcoin/bitcoin/blob/v29.0/doc/psbt.md)
