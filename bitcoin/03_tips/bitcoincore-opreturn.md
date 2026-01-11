---
layout: record
title: "Bitcoin CoreでOP_RETURNありTXを作りたい"
tags:
  - bitcoin
  - tips
daily: false
date: "2026/01/11"
---

`OP_RETURN` にあまりよい印象を抱かない人は多い。
普通に Bitcoin の転送を行う分には不要だし、
これを使うということは何かお金に関係のない情報を埋め込むことになるからだ。

というのはさておき、`OP_RETURN` をつけたトランザクションを Bitcoin Core で作る手順をメモしておく。  
regtest でしか確認していない。

## OP_RETURN に載せられる情報

`OP_RETURN` は比較的昔から存在する仕様で、
トランザクションの vout に送金額ゼロにして `OP_PUSHDATA` 系のデータだけ載せることができる。  
この vout はトランザクションの評価をする際には無視というかスキップされる。
つまり、どういうデータを載せてもよいということになっている。

* [Flow control](https://en.bitcoin.it/wiki/Script#Flow_control)
* [OP_RETURN - Storing Data on the Blockchain](https://learnmeabitcoin.com/technical/script/return/)

なんでもと言っても、サイズに関してはいろいろ仕様が変更された。
これは BIP の範疇ではなく実装依存なので Bitcoin Core の仕様が変わっただけである。  
とはいえ、デファクトスタンダードといってもよいくらいの使用率なので
仕様変更についてはものすごく議論される。  
Bitcoin Core v30 からサイズ無制限になったことで一部が分裂するようなことも起きているが、
そういう個人の好みについてはここでは触れない。  
それまでは 80バイト(`scriptPubKey` 全体で言えば 83バイト)だったので、
そのくらいにしておくのが無難だろう。

ちなみに P2WPKH, P2WSH, P2TR にはトランザクションに witness という領域があり、
そこを使うと他の領域よりも Bitcoin 手数料が 4分の1 で済む。  
なので大量に使いたいならそちらを使う人が多いと思う。  
そういう使い方自体についても議論があるがここでは触れない。

## Bitcoin Core での作り方

Bitcoin Core を使って署名まで行うので、Bitcoin Core にウォレットを持っている必要がある。  
mainnet でウォレットをもたせるのは推奨しない。
あくまでテストで使用するときだけにしておくべきだろう。
私は regtest でしか確認していない。  
なお、今の Bitcoin Core はデフォルトではウォレットは作成されないようになった。

regtest なので `bitcoin-cli generatetoaddress` などして 101 ブロック以上生成しておこう。

```bash
bitcoin-cli createwallet "wallet"
genaddr=$(bitcoin-cli getnewaddress)
bitcoin-cli generatetoaddress 101 $genaddr
bitcoin-cli getbalance
```

### 想定する使い方

送金先のアドレスと金額があり、それにプラスして特定の `OP_RETURN` データを載せないといけないという状況。

```shell
$ bitcoin-cli getnewaddress
bcrt1qaq0zf78zeshdx0uywktg4qfcwpllm7gxxetln2
```

`OP_RETURN` に載せるデータはバイナリ値になるので何でも良い。  
コマンドラインではHEX文字列を使う。

```
414243001123646566
```

### createrawtransaction

INPUT は Bitcoin Core に決めてもらうので、ここでは送金先と `OP_RETURN` だけ指定する。

```shell
$ bitcoin-cli createrawtransaction "[]" "[{\"bcrt1qaq0zf78zeshdx0uywktg4qfcwpllm7gxxetln2\":0.001},{\"data\":\"414243001123646566\"}]"
020000000002a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf90600000000000000000b6a0941424300112364656600000000
```

送金先として `"data"` を指定すると自動的に `OP_RETURN` として扱われる。  
ここから先は同じタイプのトランザクションを扱うときと同じである。

### INPUTを決めて署名して展開

`fundrawtransaction` で先ほど出力された HEX文字列を与えると INPUT を決めてくれる。

```shell
$ bitcoin-cli fundrawtransaction 020000000002a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf90600000000000000000b6a0941424300112364656600000000
{ "hex": "020000000112fa7ab7e99b8560c05839120a698cb589139d45fc0183ec33e9b542a23a688f0000000000fdffffff03a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf906bf6a042a01000000160014c2f34db10ac33615129ea4ca543940cdea44544400000000000000000b6a0941424300112364656600000000", "fee": 0.00000161, "changepos": 1 }
```

INPUT は Bitcoin Core が決めたので、署名も `signrawtransactionwithwallet` でやってもらう。

```shell
$ bitcoin-cli  signrawtransactionwithwallet 020000000112fa7ab7e99b8560c05839120a698cb589139d45fc0183ec33e9b542a23a688f0000000000fdffffff03a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf906bf6a042a01000000160014c2f34db10ac33615129ea4ca543940cdea44544400000000000000000b6a0941424300112364656600000000
{ "hex": "0200000000010112fa7ab7e99b8560c05839120a698cb589139d45fc0183ec33e9b542a23a688f0000000000fdffffff03a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf906bf6a042a01000000160014c2f34db10ac33615129ea4ca543940cdea44544400000000000000000b6a0941424300112364656602473044022016988134a4c56b2399affb25b2e3bd9686044f9f418066d5ffc6719f187d75ae022038673eaed3d2ccbe358dec128e121868fcf9cff231b3fbca99aca1b3c0ead168012102db5d1946f31331164df0da550c31e2fcdfe2b621853828daa0250e7f18b6d60e00000000", "complete": true }
```

最後に `sendrawtransaction` で展開。

```shell
$ bitcoin-cli sendrawtransaction 0200000000010112fa7ab7e99b8560c05839120a698cb589139d45fc0183ec33e9b542a23a688f0000000000fdffffff03a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf906bf6a042a01000000160014c2f34db10ac33615129ea4ca543940cdea44544400000000000000000b6a0941424300112364656602473044022016988134a4c56b2399affb25b2e3bd9686044f9f418066d5ffc6719f187d75ae022038673eaed3d2ccbe358dec128e121868fcf9cff231b3fbca99aca1b3c0ead168012102db5d1946f31331164df0da550c31e2fcdfe2b621853828daa0250e7f18b6d60e00000000
77f31ee6d67e25be3ee9c7649834dfe8ecb609c4ff52ec2e8f70232c5fe1f1a4
```

展開に成功したので `getrawtransaction` でデコードあり閲覧する。  
今回は n=2 に `"OP_RETURN 414243001123646566"` が確認できるだろう。

```shell
$ bitcoin-cli getrawtransaction 77f31ee6d67e25be3ee9c7649834dfe8ecb609c4ff52ec2e8f70232c5fe1f1a4 1
{
  "txid": "77f31ee6d67e25be3ee9c7649834dfe8ecb609c4ff52ec2e8f70232c5fe1f1a4",
  "hash": "624359949a7e5450369e8d7ec53b3f133915ef323621f3b8a9741067727af8f3",
  "version": 2,
  "size": 242,
  "vsize": 161,
  "weight": 641,
  "locktime": 0,
  "vin": [
    {
      "txid": "8f683aa242b5e933ec8301fc459d1389b58c690a123958c060859be9b77afa12",
      "vout": 0,
      "scriptSig": {
        "asm": "",
        "hex": ""
      },
      "txinwitness": [
        "3044022016988134a4c56b2399affb25b2e3bd9686044f9f418066d5ffc6719f187d75ae022038673eaed3d2ccbe358dec128e121868fcf9cff231b3fbca99aca1b3c0ead16801",
        "02db5d1946f31331164df0da550c31e2fcdfe2b621853828daa0250e7f18b6d60e"
      ],
      "sequence": 4294967293
    }
  ],
  "vout": [
    {
      "value": 0.00100000,
      "n": 0,
      "scriptPubKey": {
        "asm": "0 e81e24f8e2cc2ed33f8475968a8138707ffdf906",
        "desc": "addr(bcrt1qaq0zf78zeshdx0uywktg4qfcwpllm7gxxetln2)#cky7t7p2",
        "hex": "0014e81e24f8e2cc2ed33f8475968a8138707ffdf906",
        "address": "bcrt1qaq0zf78zeshdx0uywktg4qfcwpllm7gxxetln2",
        "type": "witness_v0_keyhash"
      }
    },
    {
      "value": 49.99899839,
      "n": 1,
      "scriptPubKey": {
        "asm": "0 c2f34db10ac33615129ea4ca543940cdea445444",
        "desc": "addr(bcrt1qcte5mvg2cvmp2y575n99gw2qeh4yg4zy2txr5z)#jh752lxg",
        "hex": "0014c2f34db10ac33615129ea4ca543940cdea445444",
        "address": "bcrt1qcte5mvg2cvmp2y575n99gw2qeh4yg4zy2txr5z",
        "type": "witness_v0_keyhash"
      }
    },
    {
      "value": 0.00000000,
      "n": 2,
      "scriptPubKey": {
        "asm": "OP_RETURN 414243001123646566",
        "desc": "raw(6a09414243001123646566)#ux7sdpua",
        "hex": "6a09414243001123646566",
        "type": "nulldata"
      }
    }
  ],
  "hex": "0200000000010112fa7ab7e99b8560c05839120a698cb589139d45fc0183ec33e9b542a23a688f0000000000fdffffff03a086010000000000160014e81e24f8e2cc2ed33f8475968a8138707ffdf906bf6a042a01000000160014c2f34db10ac33615129ea4ca543940cdea44544400000000000000000b6a0941424300112364656602473044022016988134a4c56b2399affb25b2e3bd9686044f9f418066d5ffc6719f187d75ae022038673eaed3d2ccbe358dec128e121868fcf9cff231b3fbca99aca1b3c0ead168012102db5d1946f31331164df0da550c31e2fcdfe2b621853828daa0250e7f18b6d60e00000000"
}
```
