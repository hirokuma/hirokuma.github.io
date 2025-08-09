---
layout: "record"
title: "トランザクション"
tags:
  - bitcoin
daily: false
date: "2025/04/15"
---

## はじめに

Bitcoinトランザクションには署名の方法などによる違いはあるが、データの構成は決まっている。

## 構成

* 参照
  * [Raw Transaction Format](https://developer.bitcoin.org/reference/transactions.html#raw-transaction-format)
  * [BIP-144 Serialization](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#user-content-Serialization)

Bitcoinトランザクションはバイナリデータである。  
以下はバイナリデータを構成している要素の名前である。
この名前は解説しているサイトによって多少違う(`version`が`nVersion`だったり`lock_time`が`LockTime`だったり)が、

### transaction(not witness structure)

witness structure と比較すると `marker` と `flag` がない。  
`marker = 0x00` なので、そのデータをこの not witness structure に当てはめると `txin_count` がゼロになって不可になってしまう。  
つまり、`version` の次の 1 バイトが `0x00` なら witness structure、そうでないなら not witness structure という見分け方をする。

| item | size | unit | note |
|---|---|---|---|
| version | 4 | `int32_t` |  |
| txin_count | - | compact size | `0`は不可 |
| txins[] | - | `txin[txin_count]` |  |
| txout_count | p | compact size | `0`は不可 |
| txouts[] | - | `txout[txout_count]` |  |
| lock_time | 4 | `uint32_t` |  |

segwit 以前はこの構造のみだった。

### transaction(witness structure)

| item | size | unit | note |
|---|---|---|---|
| version | 4 | `int32_t` |  |
| marker, flag | 1, 1 | `uint8_t`, `uint8_t` | `0x00`, `0x01`(BIP-141) |
| txin_count | - | compact size | `0`は不可 |
| txins[] | - | `txin[txin_count]` |  |
| txout_count | - | compact size | `0`は不可 |
| txouts[] | - | `txout[txout_count]` |  |
| script_witnesses[] | - | `script_witness[txin_count]` | |
| lock_time | 4 | `uint32_t` |  |

`script_witnesses` の数は `txin_count` と同じである。

### txin

| item | size | unit |
|---|---|---|
| txid | 32 | `char[32]` |
| index | 4 | `uint32_t` |
| scriptSig | | script |
| sequence | 4 | `uint32_t` |

### txout

| item | size | unit |
|---|---|---|
| value | 8 | `uint64_t` |
| scriptPubKey | | script |

### script_witness

`script_witness` は各 vin ごとに存在する。

* [Witness - Unlocking Code for Segwit Inputs](https://learnmeabitcoin.com/technical/transaction/witness/#structure)

| item | size | unit |
|---|---|---|
| witness_count | | compact size |
| scripts | | `stack[witness_count]` |

#### stack

`scriptSig` と違い、全体のデータ長 を compact size 型で示した後、そのサイズ分のデータが載る。  
例えば P2TR key path では 64 バイトの署名データだけなので、先頭に `0x40`、それに 64 バイトのデータが続く。  
わかりにくい違いであるが、たとえば 1 ～ 16 だけのデータをスタックに載せる場合は `OP_1` ～ `OP_16` ではなく `0x0101` ～ `0x0110` になる。  
null 値に相当するデータはデータ長 0 の `0x00` だけを使う(scriptSig と同じ)。

| item | size | unit |
|---|---|---|
| size | | compact size |
| script | size | `char[size]` |

## 説明

witness 先頭から 5byte目のデータで見分ける。  
segwit(witness)のトランザクションの場合、その位置に`0x00`が入っている。その場合は `marker(0x00)`と`flag(0x01)`が並んでいる。  
それ以外の場合は segwit非対応のトランザクションで、`marker`と`flag`がなく 5byte 目から`txin_count`のデータが入っている。

[Serialization](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#user-content-Serialization)の表に "Type" 列があるが、これがそれぞれのデータタイプである。

スクリプトの中に数値が使われる場合は命令と組み合わせて使うため [Compact Size型](value.md) とは別の表現になる([Constants](https://en.bitcoin.it/wiki/Script#Constants))。

## データ例

例としていくつか raw transaction(生のトランザクションバイナリデータ)を分解する。  
"`<script～>`" となっている項目は、先頭がデータ長でその後ろにデータ長分のデータが続いている。  
"`<script_witnesses>`" は少し特殊で、全体の数は `<txin_count>`で、それぞれスクリプトの個数とスクリプトが続いている。

#### 例1: 非segwit

[a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70](https://mempool.space/ja/testnet/tx/a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70)

```bin
<全 raw transaction データ>
01000000016e74e6814a1e0eafc9a80c8589b705f8d6791cd7a401e6046d53c38f75daae5d01000000fdfd000047304402205c97e03a51c148a15e444578e0efce7b39731f0672f5bd7ecc473810e1e1e5ec02207ca1ea0b93fd7a9a61966ab37bb3ae2d29240ee79eeb70df3660d3f47c371c5901483045022100c02f853575468daf9fbc667d1331aea792f2709ed576b6a9fe416ecb27bc0dc70220519884f5a2c39c03eab6f073a5dde4a08ef6090908a0ed14a068e30ca90c62c9014c695221021edb59dffb17e9cc4c70cc68890125216ad5a8062879be20430600138c87e0422102bae72de833cc5914d0f19a959836245d7e1b8dc0b168f289a01acdcffc02a73e2103af0b0289d979fca04aa1bb1eef1325d4dd8fbddc690297d81811c5282841f1d453aeffffffff0200911c500200000017a91401e2f991b1d8d904eea641d7971c9eee6a4e72588740420f000000000017a914e031febb6904a7e7b8192b78ab1fc6572e8d585b8700000000
--------------------------
<version>
01000000

<txin_count>
01

<txins[0]>
  <txid:index>
  6e74e6814a1e0eafc9a80c8589b705f8d6791cd7a401e6046d53c38f75daae5d01000000
  <scriptSig>
  fdfd000047304402205c97e03a51c148a15e444578e0efce7b39731f0672f5bd7ecc473810e1e1e5ec02207ca1ea0b93fd7a9a61966ab37bb3ae2d29240ee79eeb70df3660d3f47c371c5901483045022100c02f853575468daf9fbc667d1331aea792f2709ed576b6a9fe416ecb27bc0dc70220519884f5a2c39c03eab6f073a5dde4a08ef6090908a0ed14a068e30ca90c62c9014c695221021edb59dffb17e9cc4c70cc68890125216ad5a8062879be20430600138c87e0422102bae72de833cc5914d0f19a959836245d7e1b8dc0b168f289a01acdcffc02a73e2103af0b0289d979fca04aa1bb1eef1325d4dd8fbddc690297d81811c5282841f1d453aeff
  <sequence>
  ffffff

<txout_count>
02

<txouts[0]>
  <value>
  00911c5002000000
  <scriptPubkey>
  17a91401e2f991b1d8d904eea641d7971c9eee6a4e725887

<txouts[1]>
  <value>
  40420f0000000000
  <scriptPubkey>
  17a914e031febb6904a7e7b8192b78ab1fc6572e8d585b87

<lock_time>
00000000
```

#### 例2: segwit

[0931d995f2e84b610bfcc6e5a960dea3baee16229c156518d7fbaee4141d14ef](https://mempool.space/ja/testnet/tx/0931d995f2e84b610bfcc6e5a960dea3baee16229c156518d7fbaee4141d14ef)

```bin
<全 raw transaction データ>
01000000000101064c370388c7bb573fb574983e8f5740f697f45dba4dc96a16b2e31ea9034a070100000000ffffffff02314a0d00000000001600144c6a32c4a3344daf0fdc12e9202287786e5ac882e09304000000000016001468a211ede685d089ce170065948aa80790e00f9e0247304402201b3913c5ee01d6ceff87a861f8554ced9e99e281884530fd7828a50099cedad202204b641d827fcfb7c1cfd5cb7bbc4379b50f75531f063b814f4998b3507eea3033012103ec5f3495edf84da8d308bb59802a25baebab382a3c1fdccdc3462685ab09b73200000000
--------------------------
<version>
01000000

<marker, flag>
0001

<txin_count>
01

<txins[0]>
  <txid:index>
  064c370388c7bb573fb574983e8f5740f697f45dba4dc96a16b2e31ea9034a0701000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txout_count>
02

<txouts[0]>
  <value>
  314a0d0000000000
  <scriptPubkey>
  1600144c6a32c4a3344daf0fdc12e9202287786e5ac882

<txouts[1]>
  <value>
  e093040000000000
  <scriptPubkey>
  16001468a211ede685d089ce170065948aa80790e00f9e

<script_witnesses>
  <txins[0]>
    <witness_count>
    02
    <witness[0]>
    47304402201b3913c5ee01d6ceff87a861f8554ced9e99e281884530fd7828a50099cedad202204b641d827fcfb7c1cfd5cb7bbc4379b50f75531f063b814f4998b3507eea303301
    <witness[1]>
    2103ec5f3495edf84da8d308bb59802a25baebab382a3c1fdccdc3462685ab09b732

<lock_time>
00000000
```

#### 例3: segwit(P2TR key path)

[026a8f0c6e6050cf237f42a7f2ed27efffead6c8750d991f746cef44448f3e2e](https://mempool.space/ja/testnet4/tx/026a8f0c6e6050cf237f42a7f2ed27efffead6c8750d991f746cef44448f3e2e)

```bin
<全 raw transaction データ>
010000000001020ae960ef2054fd508f59b52e0ef3c19f7d2e865927f9059ec3779e568d30e9bf0100000000ffffffffb4e0d2298e0413cdb98cce33f22b240affbbd6c6eff7e9ec6eae5e70855e25bf0100000000ffffffff01bbb00100000000002251205779bec9d3f59f7b7bbefa606a81f171b3996659642bdf83a3fee52149d25e7901408893d9c6381da9984762b7bdb89427c154da5906e07678da2f8f15de292b40858fa0065170e7bca5e72cf3ce623c64533a4229527c6565d41cfb1ba411f5c1f70140093c5d8bdfdc06e33cab1f1a76bfaf93f8b5bc0a8e7d8075a7f2443772ebf648d39cac8f7bcd545c0ddfa08e62146f3079dabb284a3d47dd11280509d5cc88da00000000
--------------------------
<version>
01000000

<marker, flag>
0001

<txin_count>
02

<txins[0]>
  <txid:index>
  0ae960ef2054fd508f59b52e0ef3c19f7d2e865927f9059ec3779e568d30e9bf01000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txins[1]>
  <txid:index>
  b4e0d2298e0413cdb98cce33f22b240affbbd6c6eff7e9ec6eae5e70855e25bf01000000
  <scriptSig>
  00
  <sequence>
  ffffffff

<txout_count>
01

<txouts[0]>
  <value>
  bbb0010000000000
  <scriptPubkey>
  2251205779bec9d3f59f7b7bbefa606a81f171b3996659642bdf83a3fee52149d25e79

<script_witnesses>
  <txins[0]>
    <witness_count>
    01
    <witness[0]>
    408893d9c6381da9984762b7bdb89427c154da5906e07678da2f8f15de292b40858fa0065170e7bca5e72cf3ce623c64533a4229527c6565d41cfb1ba411f5c1f7

  <txins[1]>
    <witness_count>
    01
    <witness[0]>
    40093c5d8bdfdc06e33cab1f1a76bfaf93f8b5bc0a8e7d8075a7f2443772ebf648d39cac8f7bcd545c0ddfa08e62146f3079dabb284a3d47dd11280509d5cc88da

<lock_time>
00000000
```

#### 例4: Segwit(P2TR script path)

[cd399d2312218711c6a4a80863e7b101a40e310118bc094f601c170965133eda](https://mempool.space/ja/testnet4/tx/cd399d2312218711c6a4a80863e7b101a40e310118bc094f601c170965133eda)

```bin
<全 raw transaction データ>
02000000000101079eca858d65c783a6f4e47ee4fbe0aaa7fa28023c263a962e70888d2d1a2ad00000000000fdffffff012202000000000000225120d1c1c55764e7795ba8e627a80a78c5a140611f3dbef0464c7a0c85ca34d56a3303401b52cc0ce1a7fcfb0518dc4b9f94d31d9589c1a15dd833ad456b66dd384500dcfc47716b4c48bd7d4e4cc93759279043eaeae484202c109a665f363fcce86ce4c720585fb99f72a8daecb1beb80cd7a06deb470fc71153ef3da5043e3a47cd376c13ad0200000063406c012bb4be7567f316165c1ba71e99620638d2b78b40d5e0a0ceb629ecf4fd9678dec2fa3382247ca8d40b65025ff9e881ae5f777748b156e3826aa808d6457a2103015a7c4d2cc1c771198686e2ebef6fe7004f4136d61f6225b061d1bb9b821b9b310032697a89a1631d0ff34bfafaa20fe0af9e7de6919eae68126b3a6814c7e79a4601ab0d0000000000e8ae0d00000000006808945f0000000000007721c0585fb99f72a8daecb1beb80cd7a06deb470fc71153ef3da5043e3a47cd376c1300000000
--------------------------
<version>
02000000

<marker, flag>
0001

<txin_count>
01

<txins[0]>
  <txid:index>
  079eca858d65c783a6f4e47ee4fbe0aaa7fa28023c263a962e70888d2d1a2ad000000000
  <scriptSig>
  00
  <sequence>
  fdffffff

<txout_count>
01

<txouts[0]>
  <value>
  2202000000000000
  <scriptPubkey>
  225120d1c1c55764e7795ba8e627a80a78c5a140611f3dbef0464c7a0c85ca34d56a33

<script_witnesses>
  <txins[0]>
    <witness_count>
    03
    <witness[0]>
    401b52cc0ce1a7fcfb0518dc4b9f94d31d9589c1a15dd833ad456b66dd384500dcfc47716b4c48bd7d4e4cc93759279043eaeae484202c109a665f363fcce86ce4
    <witness[1]>
    c720585fb99f72a8daecb1beb80cd7a06deb470fc71153ef3da5043e3a47cd376c13ad0200000063406c012bb4be7567f316165c1ba71e99620638d2b78b40d5e0a0ceb629ecf4fd9678dec2fa3382247ca8d40b65025ff9e881ae5f777748b156e3826aa808d6457a2103015a7c4d2cc1c771198686e2ebef6fe7004f4136d61f6225b061d1bb9b821b9b310032697a89a1631d0ff34bfafaa20fe0af9e7de6919eae68126b3a6814c7e79a4601ab0d0000000000e8ae0d00000000006808945f00000000000077
    <witness[2]>
    21c0585fb99f72a8daecb1beb80cd7a06deb470fc71153ef3da5043e3a47cd376c13

<lock_time>
00000000
```

## TXID

個別のトランザクションを指し示すとき、通常は TXID(Transaction ID)を使う。  
データを SHA256 で 2回計算する。
データはトランザクションデータそのものではなく[こちら](https://github.com/bitcoin/bips/blob/83a1afd9859848628645c7fa200beb0dc0aea4f5/bip-0144.mediawiki#hashes)のようにデータを組む(非segwitの場合はそのまま使うことになる)。
図に出ている "Witness ID" はブロックデータを作る際に使われる。それ以外ではほぼ使われていないと思う。

計算すると 32byte のデータになる。  
例1に上げたトランザクションデータを使うと、こういう計算になる。  
上のブロックが raw transactionデータ全体を SHA256 計算したもの。
下のブロックはその SHA256 結果をさらに SHA256 計算したものになる。

[chiphereditor](https://ciphereditor.com/share#blueprint=eyJ0eXBlIjoiYmx1ZXByaW50IiwicHJvZ3JhbSI6eyJ0eXBlIjoicHJvZ3JhbSIsIm9mZnNldCI6eyJ4IjowLCJ5IjotMTAwfSwiZnJhbWUiOnsieCI6LTE2MCwieSI6LTk2LCJ3aWR0aCI6MzIwLCJoZWlnaHQiOjE5Mn0sImNoaWxkcmVuIjpbeyJ0eXBlIjoib3BlcmF0aW9uIiwibmFtZSI6IkBjaXBoZXJlZGl0b3IvZXh0ZW5zaW9uLWhhc2gvaGFzaCIsImV4dGVuc2lvblVybCI6Imh0dHBzOi8vY2RuLmNpcGhlcmVkaXRvci5jb20vZXh0ZW5zaW9ucy9AY2lwaGVyZWRpdG9yL2V4dGVuc2lvbi1oYXNoLzEuMC4wLWFscGhhLjEvZXh0ZW5zaW9uLmpzIiwicHJpb3JpdHlDb250cm9sTmFtZXMiOlsibWVzc2FnZSIsImFsZ29yaXRobSIsImhhc2giXSwiZnJhbWUiOnsieCI6LTE1NywieSI6LTQ3MCwid2lkdGgiOjMyMCwiaGVpZ2h0IjoyMzh9LCJjb250cm9scyI6eyJtZXNzYWdlIjp7InZhbHVlIjp7InR5cGUiOiJieXRlcyIsImRhdGEiOiJBUUFBQUFGdWRPYUJTaDRPcjhtb0RJV0p0d1g0MW5rYzE2UUI1Z1J0VThPUGRkcXVYUUVBQUFEOS9RQUFSekJFQWlCY2wrQTZVY0ZJb1Y1RVJYamc3ODU3T1hNZkJuTDF2WDdNUnpnUTRlSGw3QUlnZktIcUM1UDllcHBobG1xemU3T3VMU2trRHVlZTYzRGZObURUOUh3M0hGa0JTREJGQWlFQXdDK0ZOWFZHamErZnZHWjlFekd1cDVMeWNKN1ZkcmFwL2tGdXl5ZThEY2NDSUZHWWhQV2l3NXdENnJid2M2WGQ1S0NPOWdrSkNLRHRGS0JvNHd5cERHTEpBVXhwVWlFQ0h0dFozL3NYNmN4TWNNeG9pUUVsSVdyVnFBWW9lYjRnUXdZQUU0eUg0RUloQXJybkxlZ3p6RmtVMFBHYWxaZzJKRjErRzQzQXNXanlpYUFhemMvOEFxYytJUU92Q3dLSjJYbjhvRXFodXg3dkV5WFUzWSs5M0drQ2w5Z1lFY1VvS0VIeDFGT3UvLy8vL3dJQWtSeFFBZ0FBQUJlcEZBSGkrWkd4Mk5rRTdxWkIxNWNjbnU1cVRuSlloMEJDRHdBQUFBQUFGNmtVNERIK3Uya0VwK2U0R1N0NHF4L0dWeTZOV0Z1SEFBQUFBQT09In19LCJhbGdvcml0aG0iOnsidmFsdWUiOiJzaGEyNTYiLCJ2aXNpYmlsaXR5IjoiZXhwYW5kZWQifSwiaGFzaCI6eyJpZCI6IjUiLCJ2YWx1ZSI6eyJ0eXBlIjoiYnl0ZXMiLCJkYXRhIjoiZ3JoYUFKZUVydFBTUW1tR3p2Yjk0bGZDNitKL2ljS0IwbnVnOS8rTTFHaz0ifX19fSx7InR5cGUiOiJvcGVyYXRpb24iLCJuYW1lIjoiQGNpcGhlcmVkaXRvci9leHRlbnNpb24taGFzaC9oYXNoIiwiZXh0ZW5zaW9uVXJsIjoiaHR0cHM6Ly9jZG4uY2lwaGVyZWRpdG9yLmNvbS9leHRlbnNpb25zL0BjaXBoZXJlZGl0b3IvZXh0ZW5zaW9uLWhhc2gvMS4wLjAtYWxwaGEuMS9leHRlbnNpb24uanMiLCJwcmlvcml0eUNvbnRyb2xOYW1lcyI6WyJhbGdvcml0aG0iLCJtZXNzYWdlIiwiaGFzaCJdLCJmcmFtZSI6eyJ4IjotMTUwLCJ5IjotMjA0LCJ3aWR0aCI6MzIwLCJoZWlnaHQiOjIzOH0sImNvbnRyb2xzIjp7Im1lc3NhZ2UiOnsiaWQiOiI3IiwidmFsdWUiOnsidHlwZSI6ImJ5dGVzIiwiZGF0YSI6ImdyaGFBSmVFcnRQU1FtbUd6dmI5NGxmQzYrSi9pY0tCMG51ZzkvK00xR2s9In19LCJhbGdvcml0aG0iOnsidmFsdWUiOiJzaGEyNTYiLCJ2aXNpYmlsaXR5IjoiZXhwYW5kZWQifSwiaGFzaCI6eyJ2YWx1ZSI6eyJ0eXBlIjoiYnl0ZXMiLCJkYXRhIjoiY05yY3UvMDd1TVd2WVFmYm1tK1J0WHBBTVRWZVU0SjdHeXRFQnFQdjBLRT0ifX19fSx7InR5cGUiOiJ2YXJpYWJsZSIsImF0dGFjaG1lbnRzIjpbIjUiLCI3Il19XX19)

下のブロックの計算結果は [このTXID](https://mempool.space/ja/testnet/tx/a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70)の逆順になっている。

```
<計算結果>
70dadcbbfd3bb8c5af6107db9a6f91b57a4031355e53827b1b2b4406a3efd0a1

<TXID>
a1d0efa306442b1b7b82535e3531407ab5916f9adb0761afc5b83bfdbbdcda70
```

計算結果そのものの並びを "internal byte order"、逆順にした並びを "RPC byte order" と呼ばれている([用語集](https://developer.bitcoin.org/glossary.html))。  

### TXIDとWTXID

segwit(segregated witness) が登場するまで TXID はトランザクションの全データをハッシュ計算に含めていた。  
segwit 時代になってトランザクション構造が増え、トランザクションを指す ID として WTXID が追加された。  

* [Transaction ID](https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#transaction-id)

TXID は従来の TXID と同じ立ち位置で、segwit 構造のトランザクションではハッシュ値の計算に segwit 部分を除外した部分を計算に使っている。  
もう 1つは WTXID で、これはトランザクションデータ全体を計算する(以前の TXID と同じ計算方法)。

ブロックで [Merkle root hash](https://blog.hirokuma.work/bitcoin/01_basics/blocks.html#merkle-root-hash) を計算するのには WTXID を使い、それ以外では TXID を使うことが多いだろう。

### バージョン

トランザクションバージョン

#### version 1

初回のバージョン。

#### version 2

version 2 以降のトランザクションは BIP-68 に対応していることになる。

* [BIP-68](https://github.com/bitcoin/bips/blob/master/bip-0068.mediawiki#specification)
* [BIP-112](https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki)

#### version 3

version 3 はまだドラフトなようだが試作版が Bitcoin Core に実装されているとのこと。

* [Version 3 transaction relay](https://bitcoinops.org/en/topics/version-3-transaction-relay/)
* [BIP-431](https://github.com/bitcoin/bips/blob/master/bip-0431.mediawiki)
* [Bitcoin Core 28.0のポリシーを採用するウォレット用ガイド](https://bitcoinops.org/ja/bitcoin-core-28-wallet-integration-guide/)

### 署名

楕円曲線の署名をスクリプトに載せることがある。  
[DER形式](https://learnmeabitcoin.com/technical/keys/signature/#der)なのだが先頭の値が `0x80` 以上になってはいけない([stackexchange](https://bitcoin.stackexchange.com/questions/12554/why-the-signature-is-always-65-13232-bytes-long/12556#12556))。
そうなってしまう場合は頭に `0x00` を付けるようにする。  
署名は `R` と `S` の 2つで構成されるので、署名データ長だけでいうと以下の3パターンがある。

* `R` も `S` も先頭が `0x80` 未満: 2 + (2+32) + (2+32)
* `R` か `S` のどちらかの先頭が `0x80` 以上: 2 + (2+33) + (2+32)
* `R` も `S` も先頭が `0x80` 以上: 2 + (2+33) + (2+33)

つまり 70～72 バイトである。

## おわりに

[Decode Rwa Bitcoin Hexadecimal Transaction](https://live.blockcypher.com/btc/decodetx/)のようなサイトやライブラリ、`bitcoin-cli decoderawtransaction`コマンドなどを使うとトランザクション構造を知らなくても何とかなるのだが、自分でトランザクションデータを作ってブロックチェーンに展開するのであれば知っておいた方がよいと思う。

## 関連ページ

* [value](./value.md)
* [スクリプト](./script.md)
* [アドレス](./address.md)
* [ブロック](/.blocks.md)
